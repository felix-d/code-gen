import { Socket } from 'phoenix'
import { token, discountId } from './utils'

const socket = new Socket('/socket', {params: {token: token()}})

socket.connect()

const channel = socket.channel(`bulk:${discountId()}`, {})

channel.join()
  .receive('ok', resp => { console.log('Connection established.') })
  .receive('error', resp => { console.log('Unable to connect.') })

export default channel
