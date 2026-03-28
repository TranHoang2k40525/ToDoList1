using HoangRESTFul.Data;

namespace HoangRESTFul.DTO
{
    public class ToDoDto
    {
        public class ToDoCreateDto
        {
            public string? Title { get; set; }
            public string? Description { get; set; }
            public PriorityLevel Priority { get; set; }
            public DateTime? DueDate { get; set; }
            public Guid? CategoryId { get; set; }
		}
        public class ToDoResponseDto
		{
			public Guid Id { get; set; }
			public string Title { get; set; } = string.Empty;
			public string Description { get; set; } = string.Empty;
			public bool IsCompleted { get; set; }
			public string Priority { get; set; } = string.Empty;
			public string? CategoryName { get; set; }
			public DateTime? CreatedAt { get; set; }
			public Guid? CategoryId { get; set; }
			public DateTime? DueDate { get; set; }
			public DateTime? UpdatedAt { get; set; }

		}
		public class ToDoUpdateDto
		{
			public string? Title { get; set; }
			public string? Description { get; set; }
			public PriorityLevel Priority { get; set; }
			public DateTime? DueDate { get; set; }
			public Guid? CategoryId { get; set; }
			public bool? IsCompleted { get; set; }
		}

		public class TodoQueryDto
		{
			public bool? IsCompleted { get; set; }
			public PriorityLevel? Priority { get; set; }
			public Guid? CategoryId { get; set; }
			public string? Keyword { get; set; }
			public DateTime? DueFrom { get; set; }
			public DateTime? DueTo { get; set; }
			public string? SortBy { get; set; } = "createdAt";
			public string? SortOrder { get; set; } = "desc";
			public int Page { get; set; } = 1;
			public int PageSize { get; set; } = 10;
		}

		public class PagedTodoResponseDto
		{
			public int Page { get; set; }
			public int PageSize { get; set; }
			public int TotalItems { get; set; }
			public int TotalPages { get; set; }
			public IEnumerable<ToDoResponseDto> Items { get; set; } = Enumerable.Empty<ToDoResponseDto>();
		}

		public class CategoryTodoCountDto
		{
			public Guid? CategoryId { get; set; }
			public string CategoryName { get; set; } = "Uncategorized";
			public int Count { get; set; }
		}

		public class TodoStatsDto
		{
			public int Total { get; set; }
			public int Completed { get; set; }
			public int Overdue { get; set; }
			public IEnumerable<CategoryTodoCountDto> ByCategory { get; set; } = Enumerable.Empty<CategoryTodoCountDto>();
		}
	}
}
