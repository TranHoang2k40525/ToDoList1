using HoangRESTFul.DTO;
namespace HoangRESTFul.IServices
{
    public interface ITodoService
    {
        Task<ToDoDto.PagedTodoResponseDto> GetUserTodosAsync(Guid userId, ToDoDto.TodoQueryDto query);
        Task<ToDoDto.ToDoResponseDto?> GetTodoByIdAsync(Guid id, Guid userId);
        Task<ToDoDto.ToDoResponseDto> AddCreateTodosAsync(Guid userId, ToDoDto.ToDoCreateDto todo);
		Task<ToDoDto.ToDoResponseDto?> UpdateTodoAsync(Guid id, Guid userId, ToDoDto.ToDoUpdateDto todo);
		Task<bool> UpdateStatusAsync(Guid id, Guid userId);
		Task<bool> RemoveTodoAsync(Guid id, Guid userId);
		Task<ToDoDto.TodoStatsDto> GetTodoStatsAsync(Guid userId);

	}
}
