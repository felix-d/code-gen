import React from 'react'
import ShopifyPage from './ShopifyPage'
import { connect } from 'react-redux'
import {
  Button,
  FormLayout,
  Popover,
  Page,
  Banner,
  TextField,
  Card,
  Tabs,
} from '@shopify/polaris'

import socket from '../socket'
import {
  generate,
  selectTab,
  importCSV,
  uploadCSV,
  changePrefix,
  changeCodeCount,
  pending,
  error,
} from '../generation'

import PendingBanner from '../components/PendingBanner'
import SuccessBanner from '../components/SuccessBanner'
import GenerateCodes from '../components/GenerateCodes'
import ImportCSV from '../components/ImportCSV'

class Generate extends ShopifyPage  {
  constructor(props) {
    super(props)

    socket.on('progress', info => { props.doPending(info) })
    socket.on('error', () => { props.doError() })

    this.generate = this.generate.bind(this)
    this.banner = this.banner.bind(this)
    this.activeCard = this.activeCard.bind(this)
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
    } else if (this.props.error) {
      banner = (
        <Banner status="critical" title="Oops!">
          There has been a problem with your discount code creation.
          Please retry later.
        </Banner>
      )
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

  activeCard() {
    switch (this.props.selectedTabIndex) {
      case 0:
        return <GenerateCodes
          pending={this.props.pending}
          generate={this.generate}
          changePrefix={this.props.changePrefix}
          prefix={this.props.prefix}
          changeCodeCount={this.props.changeCodeCount}
          codeCount={this.props.codeCount}
        />
      case 1:
        return <ImportCSV
          csvFileName={this.props.csvFileName}
          codes={this.props.codes}
          uploadingCSV={this.props.uploadingCSV}
          pending={this.props.pending}
          importCSV={this.props.importCSV}
          uploadCSV={this.props.uploadCSV}
        />
      default:
    }
  }

  render() {
    return (
      <Page breadcrumbs={[{content: 'Go back', url: `https://${window.globals.shop}/admin/discounts/${window.globals.priceRuleId}`}]}>
        {this.banner()}
        <div id="menu-tabs">
          <Tabs
            onSelect={this.props.selectTab}
            selected={this.props.selectedTabIndex}
            tabs={[{
              id: 'generate',
              content: 'Generate discount codes',
              panelID: 'generate-panel',
            }, {
              id: 'import-csv',
              content: 'Import from CSV',
              panelID: 'csv-panel',
            }]}
          />
        </div>
        {this.activeCard()}
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
  csvFileName: state.csvFileName,
  uploadingCSV: state.uploadingCSV,
  codes: state.codes,
  error: state.status == 'error',
  selectedTabIndex: state.selectedTabIndex,
  prefix: state.prefix,
  codeCount: state.codeCount,
})

const mapDispatchToProps = {
  doPending: pending,
  generate,
  selectTab,
  doError: error,
  changePrefix,
  changeCodeCount,
  uploadCSV,
  importCSV,
}

export default connect(
  mapStateToProps,
  mapDispatchToProps,
)(Generate)
