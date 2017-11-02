import socket from './socket'
import { discountId, title } from './utils'

const CHANGE_CODE_COUNT = 'change_number_discount_codes'
const CHANGE_PREFIX = 'change_prefix'
const GENERATE = 'generate'
const PENDING = 'pending'
const COMPLETED = 'completed'
const READY = 'ready'
const USAGE_LIMIT_SET = 'usage_limit_set'
const SET_USAGE_LIMIT = 'set_usage_limit'
const DISMISS_USAGE_LIMIT_BANNER = 'dismiss_usage_limit_banner'

const initialState = {
  status: READY,
  showUsageLimitBanner: true,
  id: discountId(),
  prefix: title().substring(0, 20),
  codeCount: 100,
}

export default (state = initialState, action) => {
  switch (action.type) {
    case SET_USAGE_LIMIT:
      return {
        ...state,
        usageLimitPending: true,
      }
    case USAGE_LIMIT_SET:
      return {
        ...state,
        showUsageLimitBanner: false,
        usageLimitPending: false,
      }
    case DISMISS_USAGE_LIMIT_BANNER:
      return {
        ...state,
        showUsageLimitBanner: false,
      }
    case CHANGE_PREFIX:
      return {
        ...state,
        prefix: action.prefix,
        progress: null,
        status: READY,
      }
    case PENDING:
      return {
        ...state,
        status: PENDING,
        progress: action.progress,
        id: action.id,
        codeCount: action.codeCount,
      }
    case COMPLETED:
      return {
        ...state,
        status: COMPLETED,
        progress: null,
      }
    case CHANGE_CODE_COUNT:
      return {
        ...state,
        status: READY,
        progress: null,
        codeCount: action.count.substring(0, 4),
      }
    case GENERATE:
      return {
        ...state,
        progress: 0,
        status: PENDING,
      }
      break
    default:
      return state
  }
}

export function setUsageLimit() {
  socket.push('set_usage_limit')
  return {
    type: SET_USAGE_LIMIT,
  }
}

export function usageLimitSet() {
  return {
    type: USAGE_LIMIT_SET,
  }
}

export function dismissUsageLimitBanner() {
  return {
    type: DISMISS_USAGE_LIMIT_BANNER,
  }
}

export function generate(count, id, token, prefix) {
  socket.push('generate', { count: parseInt(count), token, id, prefix })

  return {
    type: GENERATE,
    count,
  }
}

export function changeCodeCount(count) {
  return {
    type: CHANGE_CODE_COUNT,
    count,
  }
}

export function changePrefix(prefix) {
  return {
    type: CHANGE_PREFIX,
    prefix,
  }
}

export function pending({ progress, id, code_count: codeCount }) {
  if (progress < 1) {
    return {
      type: PENDING,
      progress: progress * 100,
      id,
      codeCount,
    }
  } else {
    return {
      type: COMPLETED,
    }
  }
}
