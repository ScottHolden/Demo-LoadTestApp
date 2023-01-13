using DemoApp.Contexts;
using DemoApp.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace DemoApp.Services;

public class BookService
{
	private readonly ILogger _logger;
	private readonly BookDb _booksDb;

	public BookService(BookDb booksDb, ILoggerFactory loggerFactory)
	{
		_logger = loggerFactory.CreateLogger<BookService>();
		_booksDb = booksDb;
	}

	public async Task<Book[]> ListBooksAsync()
		=> await _booksDb.Books.ToArrayAsync();

	public async Task<Book?> GetBookAsync(int id)
		=> await _booksDb.Books.FindAsync(id);

	public async Task<Book?> AddBookAsync(Book book)
	{
		_booksDb.Add(book);
		await _booksDb.SaveChangesAsync();
		return book;
	}

	public async Task AddRandomBooksAsync(int count)
	{
		for (int i = 0; i < count; i++)
		{
			Book b = new(0, RandomName(), RandomName(), $"A {RandomWord()} book");
			await AddBookAsync(b);
		}
	}

	private static string RandomName() => string.Join(' ', Enumerable.Range(0, s_r.Next(1, 6)).Select(x => RandomWord()));
	private static string RandomWord() => s_words[s_r.Next(0, s_words.Length)];
	private static readonly Random s_r = new();
	private static readonly string[] s_words = new[] {
		"judge","flawless","amuse","stretch","dull","steep","lock","ancient","misty","gray","sheet","stew","gusty","advise","bikes","wrong","chunky","laborer","waiting","notice","daughter","refuse","painstaking","industrious","pollution","behave","wool","kindly","demonic","silk","driving","bells","knife","early","furniture","approve","cultured","hall","attack","salty"
	};
}