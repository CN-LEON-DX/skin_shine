import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String keyIngredients;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.keyIngredients,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.isFavorite = false,
  });
}

// Dữ liệu giả lập
List<Product> dummyProducts = [
  Product(
    id: 'p1',
    name: 'Hydrating Serum',
    brand: 'SkinCare Pro',
    description:
        'A lightweight, fast-absorbing serum packed with Hyaluronic Acid to deliver intense hydration, leaving skin feeling plump, smooth, and refreshed. Suitable for all skin types.',
    keyIngredients: 'With Hyaluronic Acid',
    price: 49.99,
    imageUrl: 'https://placehold.co/150x150/png',
    rating: 4.7,
    reviewCount: 125,
    isFavorite: false,
  ),
  Product(
    id: 'p2',
    name: 'Anti-Aging Cream',
    brand: 'LuxSkin',
    description:
        'Combat signs of aging with this potent cream formulated with Retinol and Peptides. Helps reduce the appearance of wrinkles and fine lines, promoting firmer, more youthful-looking skin.',
    keyIngredients: 'With Retinol & Peptides',
    price: 89.99,
    imageUrl: 'https://placehold.co/150x150/png',
    rating: 4.5,
    reviewCount: 98,
    isFavorite: true,
  ),
  Product(
    id: 'p3',
    name: 'Balancing Toner',
    brand: 'PureGlow',
    description:
        'Refine pores and balance your skin\'s pH with this gentle toner. Niacinamide helps to control excess oil and improve skin texture for a clearer, brighter complexion.',
    keyIngredients: 'With Niacinamide',
    price: 34.99,
    imageUrl: 'https://placehold.co/150x150/png',
    rating: 4.6,
    reviewCount: 150,
    isFavorite: false,
  ),
  Product(
    id: 'p4',
    name: 'Brightening Mask',
    brand: 'GlowUp',
    description:
        'This weekly treatment uses Vitamin C and AHAs to reveal brighter, more even-toned skin. Perfect for dull complexions or anyone looking to boost their natural radiance.',
    keyIngredients: 'With Vitamin C & AHAs',
    price: 42.50,
    imageUrl: 'https://placehold.co/150x150/png',
    rating: 4.8,
    reviewCount: 75,
    isFavorite: false,
  ),
  Product(
    id: 'p5',
    name: 'Gentle Cleanser',
    brand: 'SoftSkin',
    description:
        'A mild, soap-free cleanser that effectively removes makeup and impurities without stripping the skin\'s natural moisture. Ideal for sensitive and dry skin types.',
    keyIngredients: 'With Aloe & Chamomile',
    price: 28.99,
    imageUrl: 'https://placehold.co/150x150/png',
    rating: 4.4,
    reviewCount: 110,
    isFavorite: false,
  ),
]; 