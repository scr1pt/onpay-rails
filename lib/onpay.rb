#encoding:utf-8
require 'digest'

module Onpay
  class PayController

    include Onpay

    def process p, secret, lambda_hash
      @lambda_hash = lambda_hash

      p_for = p[:pay_for]
      o_a = p[:order_amount]
      o_c = p[:order_currency]

      @respond_hash = { :pay_for=>p_for,
        :order_amount=>o_a,
        :order_currency=>o_c,
        :secret => secret,
        :code => "0"
      }

      @request_hash = { :pay_for=>p_for,
        :order_amount=>o_a,
        :order_currency=>o_c.upcase,
        :secret => secret
      }

      @result = {'pay_for'=>p_for, :comment=>"OK"}

      case p[:type]
        when "check" then 
          return check_req p
        when "pay" then
          return pay_req p
      end
    end

    def check_req p
      req_md5 = gen_md5(gen_request_md5("check", @request_hash))

      if req_md5 == p[:md5] && 
          @lambda_hash[:check_payment].call(@request_hash[:pay_for])

        @result[:code] = "0"
        @respond_hash[:code] = "0"

        md5 = gen_respond_md5("check",@respond_hash)
        md5 = gen_md5(md5)

        @result[:md5] = md5

        return @result.to_xml(:root => 'result',:dasherize => false )
      else
        @respond_hash[:code] = "0"
        md5 = gen_respond_md5("check",@respond_hash)
        md5 = gen_md5(md5)

        @result[:code] = "2"
        @result[:comment] = "Внутренняя ошибка."
        @result[:md5] = md5
        return @result.to_xml(:root => 'result',:dasherize => false )
      end


    end

    def pay_req p
      @request_hash[:onpay_id] = p[:onpay_id]
      @respond_hash[:onpay_id] = p[:onpay_id]

      req_md5 = gen_md5(gen_request_pay_md5("pay", @request_hash))

      if req_md5 == p[:md5] &&
          @lambda_hash[:onpay].call(@request_hash[:pay_for])

        @result[:code] = "0"
        @respond_hash[:code] = "0"

        md5 = gen_respond_pay_md5("pay",@respond_hash)
        md5 = gen_md5(md5)

        @result[:md5] = md5
        
        return @result.to_xml(:root => 'result',:dasherize => false )
      else
        @respond_hash[:code] = "2"

        md5 = gen_respond_pay_md5("pay", @respond_hash)
        md5 = gen_md5(md5)

        @result[:code] = "2"
        @result[:comment] = "Внутренняя ошибка."
        @result[:md5] = md5
        return @result.to_xml(:root => 'result',:dasherize => false )
      end
    end
  end

  
  def gen_request_pay_md5 t, p
    str_md5 = "type;pay_for;onpay_id;order_amount;order_currency;secret_key_for_api_in"
    str_md5.gsub!(/type/,t)
    str_md5.gsub!(/onpay_id/,p[:onpay_id])
    str_md5.gsub!(/pay_for/, p[:pay_for])
    str_md5.gsub!(/order_amount/, p[:order_amount])
    str_md5.gsub!(/order_currency/, p[:order_currency])
    str_md5.gsub!(/secret_key_for_api_in/,p[:secret])
    return str_md5
  end

  def gen_respond_pay_md5 t, p
    str_md5 = "type;pay_for;onpay_id;order_id;order_amount;order_currency;code;secret_key_api_in"
    str_md5.gsub!(/order_id/, "")
    str_md5.gsub!(/type/, t)
    str_md5.gsub!(/onpay_id/,p[:onpay_id])
    str_md5.gsub!(/pay_for/, p[:pay_for])
    str_md5.gsub!(/order_amount/, p[:order_amount])
    str_md5.gsub!(/order_currency/, p[:order_currency])
    str_md5.gsub!(/code/, p[:code])
    str_md5.gsub!(/secret_key_api_in/, p[:secret])

  end

  def gen_request_md5 t, p
    str_md5 ="type;pay_for;order_amount;order_currency;secret_key_for_api_in"
    
    str_md5.gsub!(/type/,t)
    str_md5.gsub!(/pay_for/, p[:pay_for])
    str_md5.gsub!(/order_amount/, p[:order_amount])
    str_md5.gsub!(/order_currency/, p[:order_currency])
    str_md5.gsub!(/secret_key_for_api_in/,p[:secret])

    return str_md5
  end

  def gen_respond_md5 t, p
    str_md5 = "type;pay_for;order_amount;order_currency;code;secret_key_api_in"
    str_md5.gsub!(/type/, t)
    str_md5.gsub!(/pay_for/, p[:pay_for])
    str_md5.gsub!(/order_amount/, p[:order_amount])
    str_md5.gsub!(/order_currency/, p[:order_currency])
    str_md5.gsub!(/code/, p[:code])
    str_md5.gsub!(/secret_key_api_in/, p[:secret])
    return str_md5
  end

  def gen_md5(p)
    Digest::MD5.hexdigest(p).upcase
  end
end

