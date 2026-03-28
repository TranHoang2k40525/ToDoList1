using HoangRESTFul.IRespository;
using HoangRESTFul.IServices;
using HoangRESTFul.DTO;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace HoangRESTFul.Controller
{
    /// <summary>
    /// User authentication and account management endpoints
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserRespository _userRepository;
        private readonly IAuthService _authService;
        
        /// <summary>
        /// Initialize UserController with required dependencies
        /// </summary>
        public UserController(IUserRespository userRepository, IAuthService authService)
        {
            _userRepository = userRepository;
            _authService = authService;
		}
        
        /// <summary>
        /// Login user with email/username and password
        /// </summary>
        /// <param name="login">Login credentials (email/username and password)</param>
        /// <returns>JWT token if successful, error message otherwise</returns>
        /// <response code="200">Login successful, returns JWT token</response>
        /// <response code="400">Invalid credentials</response>
        [HttpPost("login")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Login ([FromBody] Login login)
        {
           var result= await _authService.LoginAsync(login);
            if(!result.Seccess)
            {
                return BadRequest(result);
            }
            return Ok(result);

		}
        
        /// <summary>
        /// Register new user account
        /// </summary>
        /// <param name="register">Registration information (username, email, password, fullname)</param>
        /// <returns>Success message if registration successful</returns>
        /// <response code="200">Registration successful</response>
        /// <response code="400">Email or username already exists</response>
        [HttpPost("register")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Register([FromBody] Register register)
        {
            var result = await _authService.RegisterAsync(register);
            if (!result.Seccess)
            {
                return BadRequest(result);
			}
            return Ok(result);
		}

        [Authorize]
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            {
                return Unauthorized();
            }

            var profile = await _authService.GetProfileAsync(userId);
            if (profile == null)
            {
                return NotFound(new { message = "User not found" });
            }

            return Ok(profile);
        }

        [Authorize]
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto request)
        {
            try
            {
                var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
                {
                    return Unauthorized();
                }

                var profile = await _authService.UpdateProfileAsync(userId, request);
                if (profile == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                return Ok(profile);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
	}
}
