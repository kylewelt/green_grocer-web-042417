require 'pry'

def consolidate_cart(cart)
  cart_hash = {}

  cart.each do |item|
    item.each do |product, details|
      if cart_hash[product]
        details[:count] = cart_hash[product][:count] += 1
      else
        details[:count] = 1
      end
      cart_hash[product] = details
    end
  end

  cart_hash
end

def apply_coupons(cart, coupons)
  cart_hash = {}

  cart.each do |product, details|
    # if we have a coupon for the current product, check the details
    if coupons.any? {|coupon| coupon[:item] == product}
      # search for all the matching coupons
      coupons.each do |coupon|
        if product == coupon[:item]
          # if the product count meets or exceeds the coupon num
          if details[:count] >= coupon[:num]
            # if the prodct w/coupon does not exist in the cart
            if !cart_hash["#{product} W/COUPON"]
              cart_hash["#{product} W/COUPON"] = {
                :price=>coupon[:cost],
                :clearance=>details[:clearance],
                :count=>1
              }
              # if the product does not exist in the cart
              if !cart_hash[product]
                cart_hash[product] = {
                  :price=>details[:price],
                  :clearance=>details[:clearance],
                  :count=>details[:count]-coupon[:num]
                }
                details[:count] = details[:count]-coupon[:num]
              # if the product exists in the cart
              else
                cart_hash[product][:count] = cart_hash[product][:count]-coupon[:num]
                details[:count] = details[:count]-coupon[:num]
              end
            # if the prodct w/coupon exists in the cart
            else
              cart_hash["#{product} W/COUPON"][:count] += cart_hash["#{product} W/COUPON"][:count]
              # if the product does not exist in the cart
              if !cart_hash[product]
                cart_hash[product] = {
                  :price=>details[:price],
                  :clearance=>details[:clearance],
                  :count=>details[:count]-coupon[:num]
                }
                details[:count] = details[:count]-coupon[:num]
              # if the product exists in the cart
              else
                cart_hash[product][:count] = cart_hash[product][:count]-coupon[:num]
                details[:count] = details[:count]-coupon[:num]
              end
            end
          # if the product count doesn't meet the coupon num
          else
            cart_hash[product] = {
              :price=>details[:price],
              :clearance=>details[:clearance],
              :count=>details[:count]
            }
          end
        end
      end
    # if no coupon for the current product, add to final cart as is
    else
      cart_hash[product] = {
        :price=>details[:price],
        :clearance=>details[:clearance],
        :count=>details[:count]
      }
    end
  end

  cart_hash
end

def apply_clearance(cart)
  # code here
  cart_hash = {}

  cart.each do |product, details|
    if details[:clearance] == true
      cart_hash[product] = {
        :price=>(details[:price]*0.8).round(2),
        :clearance=>details[:clearance],
        :count=>details[:count]
      }
    else
      cart_hash[product] = {
        :price=>details[:price],
        :clearance=>details[:clearance],
        :count=>details[:count]
      }
    end
  end

  cart_hash
end

def checkout(cart, coupons)
  puts cart
  puts coupons
  # consolidate the cart
  consolidated = consolidate_cart(cart)
  puts "CONSOLIDATED: #{consolidated}"
  # apply coupons to the consolidated cart
  couponed = apply_coupons(consolidated, coupons)
  puts "COUPONED: #{couponed}"
  # apply clearance to the couponed cart
  clearanced = apply_clearance(couponed)
  puts "CLEARANCED: #{clearanced}"
  # apply discount if the total exceeds $100
  total = 0
  clearanced.each do |product, details|
    total = total + details[:price]*details[:count]
  end

  if total > 100
    total = total*0.90
  end

  total = total.round(2)
  puts total
  total
end

# TESTING #
# cart = [
#   {"AVOCADO" => {:price => 3.00, :clearance => true}},
#   {"KALE" => {:price => 3.00, :clearance => false}},
#   {"BLACK_BEANS" => {:price => 2.50, :clearance => false}},
#   {"ALMONDS" => {:price => 9.00, :clearance => false}},
#   {"TEMPEH" => {:price => 3.00, :clearance => true}},
#   {"CHEESE" => {:price => 6.50, :clearance => false}},
#   {"BEER" => {:price => 13.00, :clearance => false}},
#   {"PEANUTBUTTER" => {:price => 3.00, :clearance => true}},
#   {"BEETS" => {:price => 2.50, :clearance => false}},
#   {"SOY MILK" => {:price => 4.50, :clearance => true}}
# ]
#
# coupons = [
#   {:item => "AVOCADO", :num => 2, :cost => 5.00},
#   {:item => "BEER", :num => 2, :cost => 20.00},
#   {:item => "CHEESE", :num => 3, :cost => 15.00}
# ]
#
# checkout(cart, coupons)
