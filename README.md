# Buckaruby PoC

Buckaruby PoC is a Rails project that demonstrates the features of [Buckaruby](https://github.com/KentaaNL/buckaruby).

## Usage

Configure the website key and secret key in your environment (.env):

```bash
BUCKAROO_WEBSITE=abcdef
BUCKAROO_SECRET=abcdef
```

Install the ruby gems:
```bash
bundle
```

Create the PostgreSQL database and migrate:
```bash
rake db:create db:migrate
```

Run the Rails server with foreman:
```bash
foreman start
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KentaaNL/buckaruby-poc.

## License

This project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
