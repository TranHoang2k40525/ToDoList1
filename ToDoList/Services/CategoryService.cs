using HoangRESTFul.IServices;
using HoangRESTFul.DTO;
using HoangRESTFul.IRespository;
using HoangRESTFul.Data;

namespace HoangRESTFul.Services
{
    public class CategoryService: ICategoryService
    {
        private readonly ICategoryRepository _categoryRepository;
        public CategoryService(ICategoryRepository categoryRepository)
        {
            _categoryRepository = categoryRepository;
		}
		public async Task<IEnumerable<Category>> GetMyCategoriesAsync(Guid userId)
        {
            var categories = await _categoryRepository.GetCategoriesAsync(userId);
            if(categories == null)
            {
                return new List<Category>();
            }
            return categories.Select(c => new Category
            {
                Id = c.Id,
                Name = c.Name,
                Icon = c.Icon,
                ColorHex = c.ColorHex
            });

		}
        public async Task<Category> CreateCategoryAsync(Guid userId, CategoryDto request)
        {
            var category = new Categories
			{
                Id = Guid.NewGuid(),
                Name = request.Name,
                Icon = request.Icon,
                ColorHex = request.ColorHex,
                UserID = userId
            };
            await _categoryRepository.AddAsync(category);
            return new Category
			{
                Id = category.Id,
                Name = category.Name,
                Icon = category.Icon,
                ColorHex = category.ColorHex
			};
		}

        public async Task<Category?> UpdateCategoryAsync(Guid userId, Guid categoryId, CategoryUpdateDto request)
        {
            var category = await _categoryRepository.GetByIdAsync(categoryId, userId);
            if (category == null)
            {
                return null;
            }

            if (!string.IsNullOrWhiteSpace(request.Name))
            {
                category.Name = request.Name;
            }
            if (!string.IsNullOrWhiteSpace(request.Icon))
            {
                category.Icon = request.Icon;
            }
            if (!string.IsNullOrWhiteSpace(request.ColorHex))
            {
                category.ColorHex = request.ColorHex;
            }

            await _categoryRepository.UpdateAsync(category);

            return new Category
            {
                Id = category.Id,
                Name = category.Name,
                Icon = category.Icon,
                ColorHex = category.ColorHex
            };
        }

        public async Task<bool> DeleteCategoryAsync(Guid userId, Guid categoryId)
        {
            var category = await _categoryRepository.GetByIdAsync(categoryId, userId);
            if (category == null)
            {
                return false;
            }

            await _categoryRepository.DeleteAsync(category);
            return true;
        }


	}
}
