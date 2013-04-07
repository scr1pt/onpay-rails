#encoding:utf-8
require 'onpay'
require "active_support/core_ext"

describe "Onpay" do

  before :all do
  @ctrl = Onpay::PayController.new
  end

  it "create a PayController" do
    @ctrl.should_not be_nil
  end

  it "check request fail" do 
    params = {
      :order_amount => "100.00",
      :order_currency => "USD",
      :pay_for => '123456',
      :type => "check",
      :md5 => "md5hash"
    }

    res = @ctrl.process params, "secret", 
      check_payment: ->(pay_for_id){return true},
      onpay: ->(pay_for_id){return true}

    res.should =~ /Внутренняя ошибка/i
  end

  it "check request normal" do 
    params = {
      :order_amount => "100.00",
      :order_currency => "USD",
      :pay_for => '123456',
      :type => "check",
      :md5 => "3D868C591334B56EFCF157D21658A199"
    }

    res = @ctrl.process params, "secret", 
      check_payment: ->(pay_for_id){return true},
      onpay: ->(pay_for_id){return true}

    res.should =~ /<code>0<\/code>/i
  end

  it "pay request fail" do 
    
  end
end