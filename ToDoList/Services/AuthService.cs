using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using HoangRESTFul.Data;
using HoangRESTFul.DTO;
using HoangRESTFul.IRespository;
using HoangRESTFul.IServices;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
namespace HoangRESTFul.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUserRespository _userRepository;
		private readonly IConfiguration _configuration;
		public AuthService(IUserRespository userRepository,  IConfiguration configuration)
        {
            _userRepository = userRepository;
            _configuration = configuration;
		}


        public async Task<AuthResponse> RegisterAsync(Register register)
        {
            if(await _userRepository.GetByEmailAsync(register.Email) != null)
            {
                return new AuthResponse
                {
                    Seccess = false,
                    Message = "Email da ton tai"
                };
            }
            if(await _userRepository.GetByUserNameAsync(register.UserName) != null)
            {
                return new AuthResponse
                {
                    Seccess = false,
                    Message = "UserName da ton tai"
                };
			}
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(register.Password);
            var account = new User
            {
                Id = Guid.NewGuid(),
                UserName = register.UserName,
                Email = register.Email,
                PasswordHash = passwordHash,
                FullName = register.FullName,
                CreatedAt = DateTime.UtcNow

            };
             await _userRepository.AddUserAsync(account);
            return new AuthResponse { Message = "Dang ky thanh cong", Seccess = true };


			}

		public async Task<AuthResponse> LoginAsync(Login login)
        {
            var user = await _userRepository.GetByEmailAsync(login.Account) ?? await _userRepository.GetByUserNameAsync(login.Account);
            if(user ==null)
            {
                return new AuthResponse
                {
                    Seccess = false,
                    Message = "Tai khoan khong ton tai"
                };
			}
            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(login.Password, user.PasswordHash);
            if (!isPasswordValid)
            {
                return new AuthResponse
                {
                    Seccess = false,
                    Message = "Mat khau khong chinh xac"
                };
            }
            // sing token
            var token = GenerateJwtToken(user);
            return new AuthResponse
            {
                Seccess = true,
                Message = "Dang nhap thanh cong",
                Token = token
            };

		}

        public async Task<UserProfileDto?> GetProfileAsync(Guid userId)
        {
            var user = await _userRepository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return null;
            }

            return new UserProfileDto
            {
                Id = user.Id,
                UserName = user.UserName,
                Email = user.Email,
                FullName = user.FullName,
                AvatarUrl = user.AvatarUrl,
                CreatedAt = user.CreatedAt
            };
        }

        public async Task<UserProfileDto?> UpdateProfileAsync(Guid userId, UpdateProfileDto request)
        {
            var user = await _userRepository.GetUserByIdAsync(userId);
            if (user == null)
            {
                return null;
            }

            if (!string.IsNullOrWhiteSpace(request.UserName) && request.UserName != user.UserName)
            {
                var existing = await _userRepository.GetByUserNameAsync(request.UserName);
                if (existing != null)
                {
                    throw new ArgumentException("UserName da ton tai");
                }
                user.UserName = request.UserName;
            }

            if (!string.IsNullOrWhiteSpace(request.FullName))
            {
                user.FullName = request.FullName;
            }

            if (!string.IsNullOrWhiteSpace(request.AvatarUrl))
            {
                user.AvatarUrl = request.AvatarUrl;
            }

            await _userRepository.UpdateUserAsync(user);

            return new UserProfileDto
            {
                Id = user.Id,
                UserName = user.UserName,
                Email = user.Email,
                FullName = user.FullName,
                AvatarUrl = user.AvatarUrl,
                CreatedAt = user.CreatedAt
            };
        }

		private string GenerateJwtToken(User user)
		{
			var jwtSecret = _configuration["Jwt:Secret"];
			var jwtIssuer = _configuration["Jwt:Issuer"];
			var jwtAudience = _configuration["Jwt:Audience"];
			var jwtExpiryMinutes = _configuration["Jwt:ExpiryMinutes"];

			var secretKey = Encoding.UTF8.GetBytes(jwtSecret!);

			var claims = new[]
			{
				new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
				new Claim(ClaimTypes.Name, user.UserName!),
				new Claim(ClaimTypes.Email, user.Email!)
			};

			var key = new SymmetricSecurityKey(secretKey);
			var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

			var token = new JwtSecurityToken(
				issuer: jwtIssuer,
				audience: jwtAudience,
				claims: claims,
				expires: DateTime.Now.AddMinutes(double.Parse(jwtExpiryMinutes!)),
				signingCredentials: creds
			);

			return new JwtSecurityTokenHandler().WriteToken(token);
		}

	}
}
