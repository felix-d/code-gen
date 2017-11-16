import React from 'react'
import ShopifyPage from './ShopifyPage'
import { connect } from 'react-redux'
import { FormLayout, Page, Banner, TextField, Card } from '@shopify/polaris'

import socket from '../socket'
import { generate, changePrefix, changeCodeCount, pending } from '../generation'

import PendingBanner from '../components/PendingBanner'
import SuccessBanner from '../components/SuccessBanner'

class Generate extends ShopifyPage  {
  constructor(props) {
    super(props)

    socket.on('progress', info => { props.doPending(info) })

    this.generate = this.generate.bind(this)
    this.banner = this.banner.bind(this)
  }

  componentWillMount() {
    if (!window.globals.priceRuleId) {
      this.props.history.replace(`/welcome${window.location.search}`)
    }
  }

  generate() {
    this.props.generate(this.props.codeCount, this.props.prefix)
  }

  banner() {
    let banner = null
    if (this.props.completed) {
      banner = <SuccessBanner codeCount={this.props.codeCount}/>
    } else if (this.props.pending) {
      banner = <PendingBanner progress={this.props.progress} />
    }
    return banner
  }

  componentDidMount() {
    ShopifyApp.Bar.loadingOff()
    const elem = document.getElementsByClassName('Polaris-Breadcrumbs__Breadcrumb')[0]
    if (elem) {
      elem.target = '_parent'
    }
  }

  render() {
    return (
      <Page breadcrumbs={[{content: 'Go back', url: `https://${window.globals.shop}/admin/discounts/${window.globals.priceRuleId}`}]}>
        {this.banner()}
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
                max={99999}
                min={0}
                label="Number of discount codes"
              />

          </FormLayout.Group>

        </FormLayout>
      </Card>
      <p className="footer">
        For support, inquiries or feature requests please contact me at <a
          href="mailto:flx.descoteaux@gmail.com?Subject=Discount%20Code%20Generator"
          target="_top"
        >
          flx.descoteaux@gmail.com
        </a>.<br/> I will do my best to get back to you as soon as possible.
      </p>
    </Page>
    )
  }
}

const mapStateToProps = state => ({
  completed: state.status === 'completed',
  pending: state.status == 'pending',
  progress: state.progress,
  prefix: state.prefix,
  codeCount: state.codeCount,
})

const mapDispatchToProps = {
  doPending: pending,
  generate,
  changePrefix,
  changeCodeCount,
}

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(Generate)
