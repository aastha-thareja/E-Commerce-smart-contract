// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Ecommerce{

    struct product{
        string title;
        string desc;
        address payable seller;
        uint productId;
        uint price;
        address buyer;
        bool delivered;
    }
    bool destroyed=false;

    modifier isNotDestroyed{
        require(!destroyed,"Contract does not esixt");
        _;
    }


    uint counter=1;
    address payable public manager;
    constructor(){
        manager=payable(msg.sender);
    }

    product[] public products;

    event registered(string title, uint productId, address seller);
    event bought(uint productId, address buyer);
    event delivered(uint productId);

    function registerProduct(string memory _title, string memory _desc, uint _price) public isNotDestroyed{
        require(_price>0,"Price should be greater than zero");
        product memory tempProduct;
        tempProduct.title=_title;
        tempProduct.desc=_desc;
        tempProduct.price=_price * 10**18; //to get price in wei
        tempProduct.seller=payable(msg.sender);
        tempProduct.productId=counter;
        products.push(tempProduct);
        counter++;
        emit registered(_title,tempProduct.productId,msg.sender);

    }
    function buy(uint _productId)payable public isNotDestroyed{
        require(products[_productId-1].price==msg.value,"Please pay the exact price"); //[_productId-1] gives the index of product[]
        require(products[_productId-1].seller!=msg.sender,"Seller cannot be buyer");  
        products[_productId-1].buyer=msg.sender;
        emit bought(_productId, msg.sender);
    }
    function delivery(uint _productId) public isNotDestroyed{
        require(products[_productId-1].buyer==msg.sender,"Only buyer can confirm");
        products[_productId-1].delivered=true;
        products[_productId-1].seller.transfer(products[_productId-1].price); //transfer money to seller if product is delivered
        emit delivered(_productId);

    }

    // function destroy()public{
    //     require(manager==msg.sender,"Only manager can call this function");
    //     selfdestruct(manager); //when this function is called, the amount in the contract will be transferred to manager
    //                             //of the contract and contract will be destroyed.
    // }
    function destroy()public isNotDestroyed{
        require(manager==msg.sender,"Only manager can call this function");
        manager.transfer(address(this).balance);
        destroyed=true;
    }

    //suppose the contract is destroyed then no function will work
    //we can use a fallback function to send back the money to the sender
    //after the contract is destroyed someone tries to buy something so with the help of fallback function we can send him back
   //he will get a message that contract doesnt exist and amount will not be deducted from his account
   
    fallback()payable external{
        payable(msg.sender).transfer(msg.value);
    }

}