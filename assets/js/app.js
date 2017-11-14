import 'phoenix_html'

import React from 'react'
import ReactDOM from 'react-dom'
import { BrowserRouter as Router, Route, Switch, Redirect } from 'react-router-dom'
import { createStore } from 'redux'
import { Provider } from 'react-redux'

import reducer from './generation'
import Welcome from './containers/Welcome'
import Generate from './containers/Generate'

// Shopify uses the same URL for both the install link and the show link in the admin.
// This causes an issue with iframes and OAuth redirection.
// See this link for more info:
// https://help.shopify.com/api/sdks/shopify-apps/embedded-app-sdk/getting-started
const isRunningInsideIFrame = window.top !== window.self
const isRunningLocally = window.location.hostname === 'localhost'
debugger
if (!isRunningInsideIFrame && !isRunningLocally) {
  window.location.href = `/install${window.location.search}`
} else {
  const store = createStore(reducer)

  ShopifyApp.init({
    apiKey: window.globals.apiClientId,
    shopOrigin: `https://${window.globals.shop}`,
    forceRedirect: false,
  });

  function redirectPath() {
    let path = null
    if (!!window.globals.priceRuleId) {
      path = '/generate'
    } else {
      path = '/welcome'
    }
    return `${path}${window.location.search}`
  }

  ReactDOM.render(
    <Provider store={store}>
      <Router>
        <Switch>
          <Route exact path="/welcome" component={Welcome}/>
          <Route exact path="/generate" component={Generate}/>
          <Redirect from="/" to={redirectPath()}/>
        </Switch>
      </Router>
    </Provider>
    , document.getElementById('app'),
  )
}

