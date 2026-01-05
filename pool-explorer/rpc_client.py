"""
Trinity RPC client interface
"""
import json
import logging
from bitcoinrpc.authproxy import AuthServiceProxy, JSONRPCException

logger = logging.getLogger(__name__)

class TrinityRPC:
    """Interface to Trinity daemon via RPC"""
    
    def __init__(self, config):
        self.config = config
        self.rpc_url = f"http://{config.RPC_USER}:{config.RPC_PASSWORD}@{config.RPC_HOST}:{config.RPC_PORT}"
        self._connection = None
    
    def _get_connection(self):
        """Get or create RPC connection"""
        try:
            return AuthServiceProxy(self.rpc_url)
        except Exception as e:
            logger.error(f"Failed to connect to Trinity daemon: {e}")
            return None
    
    def getblockcount(self):
        """Get current block count"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.getblockcount()
        except JSONRPCException as e:
            logger.error(f"RPC error in getblockcount: {e}")
        return None
    
    def getblockhash(self, height):
        """Get block hash at height"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.getblockhash(height)
        except JSONRPCException as e:
            logger.error(f"RPC error in getblockhash: {e}")
        return None
    
    def getblock(self, blockhash):
        """Get block details"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.getblock(blockhash)
        except JSONRPCException as e:
            logger.error(f"RPC error in getblock: {e}")
        return None
    
    def getdifficulty(self):
        """Get current difficulty"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.getdifficulty()
        except JSONRPCException as e:
            logger.error(f"RPC error in getdifficulty: {e}")
        return None
    
    def getmininginfo(self):
        """Get mining info"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.getmininginfo()
        except JSONRPCException as e:
            logger.error(f"RPC error in getmininginfo: {e}")
        return None
    
    def getwork(self, data=None):
        """Get work for mining or submit work"""
        try:
            conn = self._get_connection()
            if conn:
                if data:
                    return conn.getwork(data)
                else:
                    return conn.getwork()
        except JSONRPCException as e:
            logger.error(f"RPC error in getwork: {e}")
        return None
    
    def gettransaction(self, txid):
        """Get transaction details"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.gettransaction(txid)
        except JSONRPCException as e:
            logger.error(f"RPC error in gettransaction: {e}")
        return None
    
    def sendmany(self, fromaccount, amounts):
        """Send to multiple addresses"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.sendmany(fromaccount, amounts)
        except JSONRPCException as e:
            logger.error(f"RPC error in sendmany: {e}")
        return None
    
    def getinfo(self):
        """Get general info"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.getinfo()
        except JSONRPCException as e:
            logger.error(f"RPC error in getinfo: {e}")
        return None
    
    def validateaddress(self, address):
        """Validate an address"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.validateaddress(address)
        except JSONRPCException as e:
            logger.error(f"RPC error in validateaddress: {e}")
        return None
    
    def getblocktemplate(self, params=None):
        """Get block template"""
        try:
            conn = self._get_connection()
            if conn:
                if params:
                    return conn.getblocktemplate(params)
                else:
                    return conn.getblocktemplate()
        except JSONRPCException as e:
            logger.error(f"RPC error in getblocktemplate: {e}")
        return None
    
    def submitblock(self, hexdata):
        """Submit a block"""
        try:
            conn = self._get_connection()
            if conn:
                return conn.submitblock(hexdata)
        except JSONRPCException as e:
            logger.error(f"RPC error in submitblock: {e}")
        return None
