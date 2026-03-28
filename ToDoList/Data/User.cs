namespace HoangRESTFul.Data
{
    public class User
    {
        public Guid Id { get; set; }
        public string? UserName { get; set; }
        public string? Email { get; set; }
        public string? PasswordHash { get; set; }
        public string? FullName { get; set; }
        public string? AvatarUrl { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public ICollection<Categories> Categories { get; set; } = new List<Categories>();
        public ICollection<Todos> Todos { get; set; } = new List<Todos>();
    }
}
