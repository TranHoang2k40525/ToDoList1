

using HoangRESTFul.DTO;
	
	
	namespace HoangRESTFul.IServices
{
    public interface ICategoryService
    {
		Task<IEnumerable<Category>> GetMyCategoriesAsync(Guid userId);
		Task<Category> CreateCategoryAsync(Guid userId, CategoryDto request);
			Task<Category?> UpdateCategoryAsync(Guid userId, Guid categoryId, CategoryUpdateDto request);
			Task<bool> DeleteCategoryAsync(Guid userId, Guid categoryId);

	}
}
