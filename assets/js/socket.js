import { Socket } from 'phoenix'

const socket = new Socket('/socket', {params: {token: window.globals.token}})

socket.connect()

const channel = socket.channel(`bulk:${window.globals.priceRuleId}`, {})

channel.join()
  .receive('ok', resp => { console.log('Connection established.') })
  .receive('error', resp => { console.log('Unable to connect.') })

export default channel
