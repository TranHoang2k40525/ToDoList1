namespace HoangRESTFul.DTO
{
    public class Register
    {
        public string? UserName { get; set; }
        public string? Email { get; set; }
        public string? Password { get; set; }
        public string? FullName { get; set; }
    }
    public class Login
    {
        public string? Account { get; set; }
        public string? Password { get; set; }
    }
    public class AuthResponse
    {
        public bool Seccess { get; set; }
        public string? Message { get; set; }
        public string? Token { get; set; }
    }

    public class UserProfileDto
    {
        public Guid Id { get; set; }
        public string? UserName { get; set; }
        public string? Email { get; set; }
        public string? FullName { get; set; }
        public string? AvatarUrl { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class UpdateProfileDto
    {
        public string? UserName { get; set; }
        public string? FullName { get; set; }
        public string? AvatarUrl { get; set; }
    }
}