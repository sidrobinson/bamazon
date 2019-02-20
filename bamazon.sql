var mysql = require("mysql");
var inquirer = require("inquirer");


var connection = mysql.createConnection({
  host: "localhost",
  port: 3306,
  user: "root",
  password: "root",
  database: "bamazon_db"
});

//connect to mysql
connection.connect(function (err) {
  if (err) throw err;
  begin();
});

//function to propmpt user
function begin() {
  connection.query("SELECT * FROM bamazon_db.products;", function (err, result) {
    if (err) throw err;
    //onece you have items show them in the console
    console.table(result);

    inquirer.prompt([
      {
        name: "id",
        type: "input",
        message: "Enter the ID of the item you want to buy."
      }
    ])
      .then(function (answer) {
        if (err) throw err;
        var product = result[answer.id - 1].product_name;
        var id = answer.id;
        howManyUnits(product, id);
      });
  });
}

function howManyUnits(product, id) {
  var quantity;
  var price;
  var item = id;

  connection.query(
    "SELECT stock_quantity, price FROM bamazon_db.products WHERE ?",
    {
      id: id
    },
    function (err, result) {
      if (err) throw err;

      quantity = result[0].stock_quantity;
      price = result[0].price;

      inquirer.prompt([
        {
          name: "units",
          type: "input",
          message: "How many units of " + product + " would you like to buy?"
        }
      ])
        .then(function (answer) {
          var units = answer.units;

          if (units > quantity) {
            console.log("Insufficient quantity!");
            begin();
          } else {
            //order item

            orderItems(item, units, price, quantity);
          }
        });
    }
  );
}

function orderItems(item, units, price, quantity) {
  var total = quantity - units;
  var cost = units * price;

  console.log("Your cost is: $" + cost + "\n");

  connection.query(
    "UPDATE products SET ? WHERE ?",
    [
      {
        stock_quantity: total,

      },
      {
        id: item
      }
    ], function (err) {
      if (err) throw err;
      begin()
    }
  );
}