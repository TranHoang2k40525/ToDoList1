using HoangRESTFul.Data;
using HoangRESTFul.DTO;
using HoangRESTFul.IRespository;
using HoangRESTFul.IServices;

namespace HoangRESTFul.Services
{
    public class TodoService : ITodoService
	{
        private readonly ITodoRepository _todoRepository;
		public TodoService(ITodoRepository todoRepository)
		{
			_todoRepository = todoRepository;
		}

		private static ToDoDto.ToDoResponseDto MapTodo(Todos todo)
		{
			return new ToDoDto.ToDoResponseDto
			{
				Id = todo.Id,
				Title = todo.Title ?? string.Empty,
				Description = todo.Description ?? string.Empty,
				IsCompleted = todo.IsCompleted,
				Priority = todo.Priority.ToString(),
				CategoryName = todo.Categories?.Name,
				CategoryId = todo.CategoryId,
				DueDate = todo.DueDate,
				CreatedAt = todo.CreatedAt ?? DateTime.UtcNow,
				UpdatedAt = todo.UpdatedAt
			};
		}

		public async Task<ToDoDto.PagedTodoResponseDto> GetUserTodosAsync(Guid userId, ToDoDto.TodoQueryDto query)
		{
			var todos = (await _todoRepository.GetByUserIdAsync(userId)).AsQueryable();

			if (query.IsCompleted.HasValue)
			{
				todos = todos.Where(x => x.IsCompleted == query.IsCompleted.Value);
			}

			if (query.Priority.HasValue)
			{
				todos = todos.Where(x => x.Priority == query.Priority.Value);
			}

			if (query.CategoryId.HasValue)
			{
				todos = todos.Where(x => x.CategoryId == query.CategoryId.Value);
			}

			if (!string.IsNullOrWhiteSpace(query.Keyword))
			{
				var keyword = query.Keyword.Trim().ToLowerInvariant();
				todos = todos.Where(x =>
					(x.Title ?? string.Empty).ToLowerInvariant().Contains(keyword) ||
					(x.Description ?? string.Empty).ToLowerInvariant().Contains(keyword));
			}

			if (query.DueFrom.HasValue)
			{
				todos = todos.Where(x => x.DueDate.HasValue && x.DueDate.Value >= query.DueFrom.Value);
			}

			if (query.DueTo.HasValue)
			{
				todos = todos.Where(x => x.DueDate.HasValue && x.DueDate.Value <= query.DueTo.Value);
			}

			var sortBy = (query.SortBy ?? "createdAt").ToLowerInvariant();
			var desc = (query.SortOrder ?? "desc").ToLowerInvariant() == "desc";

			todos = sortBy switch
			{
				"title" => desc ? todos.OrderByDescending(x => x.Title) : todos.OrderBy(x => x.Title),
				"priority" => desc ? todos.OrderByDescending(x => x.Priority) : todos.OrderBy(x => x.Priority),
				"duedate" => desc ? todos.OrderByDescending(x => x.DueDate) : todos.OrderBy(x => x.DueDate),
				"updatedat" => desc ? todos.OrderByDescending(x => x.UpdatedAt) : todos.OrderBy(x => x.UpdatedAt),
				_ => desc ? todos.OrderByDescending(x => x.CreatedAt) : todos.OrderBy(x => x.CreatedAt)
			};

			var page = query.Page <= 0 ? 1 : query.Page;
			var pageSize = query.PageSize <= 0 ? 10 : query.PageSize;

			var totalItems = todos.Count();
			var items = todos.Skip((page - 1) * pageSize).Take(pageSize).ToList();

			return new ToDoDto.PagedTodoResponseDto
			{
				Page = page,
				PageSize = pageSize,
				TotalItems = totalItems,
				TotalPages = (int)Math.Ceiling(totalItems / (double)pageSize),
				Items = items.Select(MapTodo).ToList()
			};
		}

		public async Task<ToDoDto.ToDoResponseDto?> GetTodoByIdAsync(Guid id, Guid userId)
		{
			var todo = await _todoRepository.GetByIdAsync(id);
			if (todo == null || todo.UserId != userId)
			{
				return null;
			}

			return MapTodo(todo);
		}

		public async Task<ToDoDto.ToDoResponseDto> AddCreateTodosAsync(Guid userId, ToDoDto.ToDoCreateDto todo)
		{
			if (todo.CategoryId.HasValue && todo.CategoryId.Value != Guid.Empty)
			{
				var categoryBelongs = await _todoRepository.CategoryBelongsToUserAsync(todo.CategoryId.Value, userId);
				if (!categoryBelongs)
				{
					throw new ArgumentException("Category khong hop le");
				}
			}

			var todoEntity = new Todos
			{
				Id = Guid.NewGuid(),
				Title = todo.Title,
				Description = todo.Description,
				Priority = todo.Priority,
				DueDate = todo.DueDate,
				CategoryId = todo.CategoryId,
				UserId = userId,
				IsCompleted = false,
				CreatedAt = DateTime.UtcNow,
				UpdatedAt = DateTime.UtcNow
			};

			await _todoRepository.AddTodoAsync(todoEntity);
			var created = await _todoRepository.GetByIdAsync(todoEntity.Id);
			return MapTodo(created ?? todoEntity);
		}

		public async Task<ToDoDto.ToDoResponseDto?> UpdateTodoAsync(Guid id, Guid userId, ToDoDto.ToDoUpdateDto todo)
		{
			var entity = await _todoRepository.GetByIdAsync(id);
			if (entity == null || entity.UserId != userId)
			{
				return null;
			}

			if (todo.CategoryId.HasValue && todo.CategoryId.Value != Guid.Empty)
			{
				var categoryBelongs = await _todoRepository.CategoryBelongsToUserAsync(todo.CategoryId.Value, userId);
				if (!categoryBelongs)
				{
					throw new ArgumentException("Category khong hop le");
				}
			}

			entity.Title = todo.Title;
			entity.Description = todo.Description;
			entity.Priority = todo.Priority;
			entity.DueDate = todo.DueDate;
			entity.CategoryId = todo.CategoryId;
			if (todo.IsCompleted.HasValue)
			{
				entity.IsCompleted = todo.IsCompleted.Value;
			}
			entity.UpdatedAt = DateTime.UtcNow;

			await _todoRepository.UpdateTodoAsync(entity);
			var updated = await _todoRepository.GetByIdAsync(entity.Id);
			return MapTodo(updated ?? entity);
		}

		public async Task<bool> UpdateStatusAsync(Guid id, Guid userId)
		{
			var todo = await _todoRepository.GetByIdAsync(id);
			if (todo == null || todo.UserId != userId)
			{
				return false;
			}

			todo.IsCompleted = !todo.IsCompleted;
			todo.UpdatedAt = DateTime.UtcNow;
			await _todoRepository.UpdateTodoAsync(todo);
			return true;
		}

		public async Task<bool> RemoveTodoAsync(Guid id, Guid userId)
		{
			var todo = await _todoRepository.GetByIdAsync(id);
			if (todo == null || todo.UserId != userId)
			{
				return false;
			}

			await _todoRepository.DeleteTodoAsync(id);
			return true;
		}

		public async Task<ToDoDto.TodoStatsDto> GetTodoStatsAsync(Guid userId)
		{
			var todos = (await _todoRepository.GetByUserIdAsync(userId)).ToList();
			var now = DateTime.UtcNow;

			var byCategory = todos
				.GroupBy(x => new { x.CategoryId, Name = x.Categories != null ? x.Categories.Name : "Uncategorized" })
				.Select(g => new ToDoDto.CategoryTodoCountDto
				{
					CategoryId = g.Key.CategoryId,
					CategoryName = g.Key.Name ?? "Uncategorized",
					Count = g.Count()
				})
				.ToList();

			return new ToDoDto.TodoStatsDto
			{
				Total = todos.Count,
				Completed = todos.Count(x => x.IsCompleted),
				Overdue = todos.Count(x => !x.IsCompleted && x.DueDate.HasValue && x.DueDate.Value < now),
				ByCategory = byCategory
			};
		}
	}
}
