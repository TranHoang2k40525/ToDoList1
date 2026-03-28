using HoangRESTFul
    .DTO;
namespace HoangRESTFul.IServices
{
    public interface IAuthService
    {
        Task<AuthResponse> LoginAsync(Login login);
        Task<AuthResponse> RegisterAsync(Register register);
            Task<UserProfileDto?> GetProfileAsync(Guid userId);
            Task<UserProfileDto?> UpdateProfileAsync(Guid userId, UpdateProfileDto request);
	}
}
