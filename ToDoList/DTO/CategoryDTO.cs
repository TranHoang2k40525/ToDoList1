namespace HoangRESTFul.DTO
{
   public class CategoryDto
	{
		public string Name { get; set; } = string.Empty;
		public string? Icon { get; set; }
		public string? ColorHex { get; set; }
	}
	public class Category
	{
		public Guid Id { get; set; }
		public string Name { get; set; } = string.Empty;
		public string? Icon { get; set; }
		public string? ColorHex { get; set; }

	}

	public class CategoryUpdateDto
	{
		public string? Name { get; set; }
		public string? Icon { get; set; }
		public string? ColorHex { get; set; }
	}
}
