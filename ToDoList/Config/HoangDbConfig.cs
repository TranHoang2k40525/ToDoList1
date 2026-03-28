using HoangRESTFul.Data;
using Microsoft.EntityFrameworkCore;

namespace HoangRESTFul.Config
{
    public class HoangDbConfig : DbContext
    {
        public HoangDbConfig(DbContextOptions<HoangDbConfig> option) : base(option)
        {

        }
        public DbSet<User> User { get; set; }
        public DbSet<Categories> Categories { get; set; }
        public DbSet<Todos> Todos { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<User>(e =>
            {
                e.HasKey(e => e.Id);
                e.Property(e => e.UserName).IsRequired().HasMaxLength(50);
                e.Property(e => e.Email).IsRequired().HasMaxLength(200);
                e.Property(e => e.PasswordHash).IsRequired().HasMaxLength(500);
                e.Property(e => e.FullName).HasMaxLength(100);



            });
            modelBuilder.Entity<Categories>(c =>
            {
                c.HasKey(c => c.Id);
                c.Property(c => c.Name).IsRequired().HasMaxLength(100);
                c.Property(c => c.Icon).HasMaxLength(50);
                c.Property(c => c.ColorHex).HasMaxLength(7);
                c.Property(c => c.UserID).IsRequired();
                c.HasOne(c => c.User).WithMany(u => u.Categories).HasForeignKey(c => c.UserID).OnDelete(DeleteBehavior.Cascade);
            });
            modelBuilder.Entity<Todos>(t =>
            {
                t.HasKey(t => t.Id);
                t.Property(t => t.Title).HasMaxLength(200);
                t.Property(t => t.Description).HasMaxLength(1000);
                t.Property(t => t.UserId).IsRequired();
                t.HasOne(t => t.User).WithMany(u => u.Todos).HasForeignKey(t => t.UserId).OnDelete(DeleteBehavior.Restrict);
                t.HasOne(t => t.Categories).WithMany(c => c.Todos).HasForeignKey(t => t.CategoryId).OnDelete(DeleteBehavior.SetNull);
            });
        }
    }
}
