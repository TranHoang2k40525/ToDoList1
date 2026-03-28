using HoangRESTFul.Data;

namespace HoangRESTFul.IRespository
{
    public interface ICategoryRepository
    {
        Task<IEnumerable<Categories>> GetCategoriesAsync(Guid userId);
        Task<Categories> GetByIdAsync(Guid id, Guid userId);
        Task AddAsync(Categories category);
        Task UpdateAsync(Categories category);
        Task DeleteAsync(Categories category);


	}
}
