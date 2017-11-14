import React from 'react'
import ShopifyPage from './ShopifyPage'
import { Page, Card } from '@shopify/polaris'

export default class Welcome extends ShopifyPage {
  render() {
    return (
      <Page>
        <Card
          title="1. Choose a discount"
          sectioned>
          <p>Click <em>Generate discount codes</em> from the <em>More actions</em> menu on any existing discount page.
            Start by <a target="_parent" href={`https://${window.globals.shop}/admin/discounts`}>selecting an existing discount</a>&nbsp;
            or <a target="_parent" href={`https://${window.globals.shop}/admin/discounts/new`}>creating a new discount</a>.
          </p>
          <div className="welcome-screenshot"><img src="images/screen1.jpg" alt="Screenshot 1"/></div>
        </Card>
        <Card
          title="2. Specify a prefix and a code count"
          sectioned>
          <p>Edit or remove the prefix prepended to generated codes if required and specify the number of codes you want to generate.</p>
          <div className="welcome-screenshot"><img src="images/screen2.jpg" alt="Screenshot 2"/></div>
        </Card>
        <Card
          title="3. Click on Generate"
          sectioned>
          <p>Click on the "Generate" button and get live feedback of your discount code creation. You can also safely leave the page and come back anytime to it as the creation runs in the background. It's also possible to generate codes for another discount at the same time. Note, however, that the creation will be queued behind the other one so it will take more time to complete.</p>
          <div className="welcome-screenshot"><img src="images/screen3.jpg" alt="Screenshot 3"/></div>
        </Card>
        <Card
          title="4. Tada!"
          sectioned>
          <p>Once the creation is completed, you can now access your codes. To do so, simply click on the link displayed on the banner.</p>
          <div className="welcome-screenshot"><img src="images/screen4.jpg" alt="Screenshot 3"/></div>
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
