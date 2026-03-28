using HoangRESTFul.IRespository;
using HoangRESTFul.Data;
using Microsoft.EntityFrameworkCore;
using HoangRESTFul.Config;

namespace HoangRESTFul.Respository
{
    public class UserRespository : IUserRespository
    {
        private readonly HoangDbConfig _context;
        public UserRespository(HoangDbConfig context)
        {
            _context = context;
        }
        public async Task<User?> GetUserByIdAsync(Guid id)
        {
            return await _context.User.FirstOrDefaultAsync(u => u.Id == id);
        }
        public async Task<User?> GetByEmailAsync(string email)
        {
            return await _context.User.FirstOrDefaultAsync(u => u.Email == email);
        }
        public async Task AddUserAsync(User user)
        {
             _context.User.Add(user);
			await _context.SaveChangesAsync();
		}
        public async Task UpdateUserAsync(User user)
        {
                       _context.User.Update(user);
            await _context.SaveChangesAsync();
		}
        public async Task<User?> GetByUserNameAsync(string userName)
        {
            return await _context.User.FirstOrDefaultAsync(u => u.UserName == userName);
		}

	}
}
