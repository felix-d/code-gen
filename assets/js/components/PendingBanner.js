import React from 'react'
import { endsWith } from 'lodash'
import { Banner, ProgressBar } from '@shopify/polaris'
import { ordinalIndicator } from '../utils'

export default ({ progress }) => {
  return (
    <Banner
      title={"Please wait..."}
      status="status"
    >
    <ProgressBar progress={parseInt(progress, 10)} size="large"/>
    </Banner>
  )
}
