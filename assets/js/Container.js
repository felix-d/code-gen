import socket from './socket'
import React, { Component } from 'react'
import { Spinner, Layout, FormLayout, Page, Banner, TextField, Card } from '@shopify/polaris'
import { Link } from 'react-router-dom'
import { connect } from 'react-redux'
import { includes } from 'lodash'
import { generate, changePrefix, changeCodeCount, pending, setUsageLimit, usageLimitSet, dismissUsageLimitBanner } from './generation'
import { token, discountId, shop, usageLimit } from './utils'

import PendingBanner from './components/PendingBanner'
import SuccessBanner from './components/SuccessBanner'
import UsageLimitBanner from './components/UsageLimitBanner'
import Welcome from './components/Welcome'

import { getParameterByName } from './utils'

class Container extends Component  {
  constructor(props) {
    super(props)

    socket.on('progress', info => { props.doPending(info) })
    socket.on('usage_limit_set', () => { props.usageLimitSet() })

    this.generate = this.generate.bind(this)
    this.banner = this.banner.bind(this)
    this.onDismissUsageLimitBanner = this.onDismissUsageLimitBanner.bind(this)
    this.onSetUsageLimit = this.onSetUsageLimit.bind(this)
  }

  onDismissUsageLimitBanner() {
    this.props.dismissUsageLimitBanner()
  }

  onSetUsageLimit() {
    this.props.setUsageLimit()
  }

  generate() {
    this.props.generate(this.props.codeCount, discountId(), token(), this.props.prefix)
  }

  banner() {
    let banner = null
    if (this.props.completed) {
      banner = <SuccessBanner discountId={discountId()} codeCount={this.props.codeCount}/>
    } else if (this.props.pending) {
      banner = <PendingBanner progress={this.props.progress} />
    }
    return banner
  }

  componentDidMount() {
    const elem = document.getElementsByClassName('Polaris-Breadcrumbs__Breadcrumb')[0]
    if (elem) {
      elem.target = '_parent'
    }
  }

  render() {
    const breadcrumbs = !!discountId() ? [{content: 'Go back', url: `https://${shop()}/admin/discounts/${discountId()}`}] : null
    return (
      <Page breadcrumbs={breadcrumbs}>
        {this.banner()}
        {!!discountId() ?
            <Card
              sectioned
              primaryFooterAction={{
                content: 'Generate',
                loading: this.props.pending,
                onClick: this.generate
              }}
              title="Generate discount codes"
            >
                <FormLayout>
                  <FormLayout.Group>
                <TextField
                  type="text"
                  onChange={this.props.changePrefix}
                  disabled={this.props.pending}
                  value={this.props.prefix}
                  placeholder="None"
                  maxLength={20}
                  label="Code prefix"
                />
                <TextField
                  onChange={this.props.changeCodeCount}
                  disabled={this.props.pending}
                  type="number"
                  value={this.props.codeCount}
                  max={9999}
                  min={0}
                  label="Number of discount codes"
                />

            </FormLayout.Group>

              </FormLayout>
          </Card> : <Welcome/>
        }
      </Page>
    )
  }
}

const mapStateToProps = state => ({
  completed: state.status === 'completed',
  pending: state.status == 'pending',
  ready: state.status == 'ready',
  progress: state.progress,
  showUsageLimitBanner: state.showUsageLimitBanner,
  usageLimitPending: state.usageLimitPending,
  prefix: state.prefix,
  codeCount: state.codeCount,
})

const mapDispatchToProps = {
  dismissUsageLimitBanner,
  setUsageLimit,
  usageLimitSet,
  doPending: pending,
  generate,
  changePrefix,
  changeCodeCount,
}

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(Container)
