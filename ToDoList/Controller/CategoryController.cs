using Microsoft.AspNetCore.Mvc;
using HoangRESTFul.IServices;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using HoangRESTFul.DTO;

namespace HoangRESTFul.Controller
{
	/// <summary>
	/// Category management endpoints (requires JWT authentication)
	/// </summary>
	[ApiController]
	[Route("api/[controller]")]
	[Authorize]
	public class CategoryController : ControllerBase
	{

		private readonly ICategoryService _categoryService;
		
		/// <summary>
		/// Initialize CategoryController with required service
		/// </summary>
		public CategoryController(ICategoryService categoryService)
		{
			_categoryService = categoryService;
		}
		
		/// <summary>
		/// Get all categories for the current user
		/// </summary>
		/// <returns>List of categories</returns>
		/// <response code="200">Returns list of user's categories</response>
		/// <response code="401">Unauthorized - JWT token required</response>
		[HttpGet("category")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status401Unauthorized)]
		public async Task<IActionResult> GetCategory()
		{
			var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
			if (userId == Guid.Empty)
			{
				return Unauthorized();
			}
			var categories = await _categoryService.GetMyCategoriesAsync(userId);
			return Ok(categories);

		}
		
		/// <summary>
		/// Create a new category
		/// </summary>
		/// <param name="request">Category details to create</param>
		/// <returns>Created category</returns>
		/// <response code="200">Category created successfully</response>
		/// <response code="401">Unauthorized - JWT token required</response>
		[HttpPost("category")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status401Unauthorized)]
		public async Task<IActionResult> CreateCategory([FromBody] CategoryDto request)
		{
			var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
			if (userId == Guid.Empty)
			{
				return Unauthorized();
			}
			var category = await _categoryService.CreateCategoryAsync(userId, request);
			return Ok(category);
		}

		[HttpPut("category/{id}")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status404NotFound)]
		public async Task<IActionResult> UpdateCategory([FromRoute] Guid id, [FromBody] CategoryUpdateDto request)
		{
			var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
			if (userId == Guid.Empty)
			{
				return Unauthorized();
			}

			var category = await _categoryService.UpdateCategoryAsync(userId, id, request);
			if (category == null)
			{
				return NotFound(new { message = "Category not found" });
			}

			return Ok(category);
		}

		[HttpDelete("category/{id}")]
		[ProducesResponseType(StatusCodes.Status200OK)]
		[ProducesResponseType(StatusCodes.Status404NotFound)]
		public async Task<IActionResult> DeleteCategory([FromRoute] Guid id)
		{
			var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
			if (userId == Guid.Empty)
			{
				return Unauthorized();
			}

			var deleted = await _categoryService.DeleteCategoryAsync(userId, id);
			if (!deleted)
			{
				return NotFound(new { message = "Category not found" });
			}

			return Ok(new { message = "Category deleted successfully" });
		}
	}
}
