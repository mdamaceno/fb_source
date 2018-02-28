# FB Source

It makes a backup of procedures, triggers and views from a Firebird database. It is made to run on a server, preferably with cron.

## Getting Started

**FB Source** uses Ruby, so you need to have it installed on your machine. I recommend install Ruby via [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv).

Clone the repository:

``` bash
$ git clone https://github.com/mdamaceno/fb_source.git && cd fb_source
```

Create a file called .env with the following structure:

```
DATABASE_HOST=localhost
DATABASE_PORT=3050
DATABASE_NAME=/path-to-database/DATABASE.GDB
DATABASE_USERNAME=username
DATABASE_PASSWORD=password

OUTPUT_PATH=./output-path
```

Change the values as needed.

## Usage

Go to **FB Source**'s root folder and run the command:

``` bash
$ ruby run.rb
```

This command generates the files with SQL script in the procedures, triggers and views folders located in output directory.

Optionally, you can change the output directory passing parameters to the command:

```
-o, --output PATH  # custom output path
```

## Contributing

All the contributions are welcome. Submit your pull request!

## Authors

See the list of [contributors](contributors.md) who participated in this project.

## License

This project is licensed under the MIT License.