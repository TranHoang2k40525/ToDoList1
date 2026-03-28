namespace HoangRESTFul.Data
{
    public class Todos
    {
        public Guid Id { get; set; }
        public string? Title { get; set; }
        public string Description { get; set; }
        public bool IsCompleted { get; set; }
        public PriorityLevel Priority { get; set; }

        public DateTime? DueDate { get; set; }
        public DateTime? ReminderTime { get; set; }
        public DateTime? CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; } = DateTime.Now;
        public Guid? CategoryId { get; set; }
        public Categories? Categories { get; set; }
        public Guid UserId { get; set; }
        public User? User { get; set; }

    }
    public enum PriorityLevel
    {
        Low,
        Medium,
        High

    }


}
