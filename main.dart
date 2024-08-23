import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // เพิ่มการ import นี้
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class Product {
  final String title;
  final double price;
  final String image;
  final String category;
  final Rating? rating;

  Product({
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'],
      price: json['price'].toDouble(),
      image: json['image'],
      category: json['category'],
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
    );
  }
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: json['rate'].toDouble(),
      count: json['count'],
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    var url = Uri.https("fakestoreapi.com", "products");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        products = jsonResponse.map((data) => Product.fromJson(data)).toList();
      });
    } else {
      print('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WU Shop")),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
                var imgUrl = product.image.isNotEmpty
                    ? product.image
                    : "https://icon-library.com/images/no-picture-available-icon/no-picture-available-icon-20.jpg";

                return ListTile(
                  title: Text(product.title),
                  subtitle: Text("\$${product.price}"),
                  leading: AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.network(imgUrl, fit: BoxFit.cover),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    var imgUrl = product.image.isNotEmpty
        ? product.image
        : "https://icon-library.com/images/no-picture-available-icon/no-picture-available-icon-20.jpg";

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Image.network(imgUrl),
            ),
            SizedBox(height: 16),
            Text(
              product.title,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "\$${product.price}",
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 8),
            Text(
              "Category: ${product.category}",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),

            // เพิ่มคำอธิบายสินค้า (Description)
            Text(
              "great outerwear jackets for Spring/Autumn/Winter, "
              "various occasions, such as working, hiking, camping, "
              "mountain/rock climbing, cycling, traveling or other outdoor activities.",
              style: TextStyle(fontSize: 16.0),
            ),

            SizedBox(height: 8),

            if (product.rating != null)
              Text(
                "Rating: ${product.rating!.rate}/5 of ${product.rating!.count}",
              ),
            if (product.rating != null)
              RatingBar.builder(
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) => print(value),
                minRating: 0,
                itemCount: 5,
                allowHalfRating: true,
                direction: Axis.horizontal,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                initialRating: product.rating!.rate,
              ),
          ],
        ),
      ),
    );
  }
}

