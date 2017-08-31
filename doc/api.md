How to generate documentation
-----------------------------

1. Configure your test database.

    View the example of `database.yml` in `config/database.examlple.yml`.

    You can clone your production database by `CREATE DATABASE yeti_test WITH TEMPLATE yeti;` and `CREATE DATABASE yeti_cdr_test WITH TEMPLATE cdr;`

    Never use your production database as test database!
2. Run `rake docs:generate` in terminal.

How to read documentation
-------------------------

1. Configure your development database.
2. Run the application in the development environment.
3. Visit `api/docs`. This is "Admin JSON API Documentation"
4. Open in browser `doc/api/customer/v1/index.html` (without web server). This is "Customer/V1 JSON API Documentation".
