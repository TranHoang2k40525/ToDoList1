using HoangRESTFul.Data;

namespace HoangRESTFul.IRespository
{
    public interface ITodoRepository
    {
        Task<IEnumerable<Todos>> GetByUserIdAsync(Guid id);
        Task<Todos> GetByIdAsync(Guid id);
        Task AddTodoAsync (Todos todo);
        Task UpdateTodoAsync (Todos todo);
        Task DeleteTodoAsync (Guid id);
        Task<bool> CategoryExistsAsync(Guid categoryId);
		Task<bool> CategoryBelongsToUserAsync(Guid categoryId, Guid userId);


	}
}
