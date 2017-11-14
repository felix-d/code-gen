import React, { Component } from 'react'

export default class ShopifyPage extends Component {
  componentDidMount() {
    ShopifyApp.Bar.loadingOff()
  }
}
