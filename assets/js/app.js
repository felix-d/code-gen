import 'phoenix_html'

import React from 'react'
import ReactDOM from 'react-dom'
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom'
import { createStore } from 'redux'
import { Provider } from 'react-redux'

import reducer from './generation'
import Container from './Container'

const store = createStore(reducer)

ReactDOM.render(
  <Provider store={store}>
    <Router>
      <Switch>
        <Route exact path="/" component={Container}/>
      </Switch>
    </Router>
  </Provider>
  , document.getElementById('app'),
)
