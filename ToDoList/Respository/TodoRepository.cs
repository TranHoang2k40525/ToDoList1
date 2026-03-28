using Microsoft.EntityFrameworkCore;
using HoangRESTFul.Data;
using HoangRESTFul.Config;
using HoangRESTFul.IRespository;
namespace HoangRESTFul.Respository
{
    public class TodoRepository : ITodoRepository
    {
        private readonly HoangDbConfig _context;
        public TodoRepository(HoangDbConfig context)
        {
            _context = context;
        }
        public async Task<IEnumerable<Todos>> GetByUserIdAsync(Guid id)
        {
            return await _context.Todos
                .Include(t => t.Categories)
                .Where(t => t.UserId == id)
                .ToListAsync();


        }
        public async Task<Todos> GetByIdAsync(Guid id)
        {
            return await _context.Todos
                .Include(t => t.Categories)
                .Where(t => t.Id == id)
                .FirstOrDefaultAsync();
        }
        public async Task AddTodoAsync(Todos todo)
        {
            _context.Todos.Add(todo);
            await _context.SaveChangesAsync();
        }
        public async Task UpdateTodoAsync(Todos todo)
        {
            _context.Todos.Update(todo);
            await _context.SaveChangesAsync();
        }
        public async Task DeleteTodoAsync(Guid id)
        {
            var todo = await _context.Todos.FindAsync(id);
            if (todo != null)
            {
                _context.Todos.Remove(todo);
                await _context.SaveChangesAsync();
            }
            else
            {
                throw new Exception("Todo not found");

            }
        }

        public async Task<bool> CategoryExistsAsync(Guid categoryId)
        {
            return await _context.Categories.AnyAsync(c => c.Id == categoryId);
        }

        public async Task<bool> CategoryBelongsToUserAsync(Guid categoryId, Guid userId)
        {
            return await _context.Categories.AnyAsync(c => c.Id == categoryId && c.UserID == userId);
        }
    }
}
