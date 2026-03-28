using HoangRESTFul.Data;


namespace HoangRESTFul.IRespository
{
    public interface IUserRespository
    {
        Task<User?> GetUserByIdAsync(Guid id);
        Task<User?> GetByEmailAsync(string email);
        Task AddUserAsync(User user);
       
        Task UpdateUserAsync(User user);
        Task<User?> GetByUserNameAsync(string userName);
	}
}
