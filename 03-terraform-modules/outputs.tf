output "blog_url"{
    description = "URL of the blog site"
    value = module.blog.wordpress_url
}

output "shop_url"{
    description = "URL of the shop site"
    value = module.shop.wordpress_url
}

output "portfolio_url"{
    description = "URL of the portfolio site"
    value = module.portfolio.wordpress_url
}