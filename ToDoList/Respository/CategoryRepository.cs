using HoangRESTFul.IRespository;
using HoangRESTFul.Data;
using Microsoft.EntityFrameworkCore;
using HoangRESTFul.Config;

namespace HoangRESTFul.Respository
{
	public class CategoryRepository : ICategoryRepository
	{
		private readonly HoangDbConfig _context;
		public CategoryRepository(HoangDbConfig context)
		{
			_context = context;
		}
		public async Task<IEnumerable<Categories>> GetCategoriesAsync(Guid userId)
		{
			return await _context.Categories.Where(c => c.UserID == userId).ToListAsync();

		}
		public async Task<Categories> GetByIdAsync(Guid id, Guid userId)
		{
			var result = await _context.Categories.FirstOrDefaultAsync(c => c.Id == id && c.UserID == userId);
			return result;
		}
		public async Task AddAsync(Categories category)
		{
			_context.Categories.Add(category);
			await _context.SaveChangesAsync();
		}
		public async Task UpdateAsync(Categories category)
		{
			_context.Categories.Update(category);
			await _context.SaveChangesAsync();
		}
		public async Task DeleteAsync(Categories category)
		{
			_context.Categories.Remove(category);
			await _context.SaveChangesAsync();
		}
	}
}
