namespace HoangRESTFul.Data
{
    public class Categories
    {
        public Guid Id { get; set; }
        public string? Name { get; set; }
        public string? Icon { get; set; }
        public string? ColorHex { get; set; }
        public Guid UserID { get; set; }
        public User? User { get; set; }
        public ICollection<Todos> Todos { get; set; } = new List<Todos>();

    }
}
