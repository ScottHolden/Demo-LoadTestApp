using DemoApp.Models;
using Microsoft.EntityFrameworkCore;

namespace DemoApp.Contexts;

public class BookDb : DbContext
{
	public BookDb(DbContextOptions<BookDb> options)
		: base(options) { }

	public DbSet<Book> Books => Set<Book>();
}
