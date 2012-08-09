-- | Simple module to wrap yesod-routes for use with WAI
module Network.Wai.Dispatch (dispatch, Route(..), Piece(..)) where

import Data.Maybe (fromMaybe)
import Network.Wai (Application, Request(pathInfo, requestMethod), Response)
import Yesod.Routes.Dispatch (Route(..), Piece(..), toDispatch)
import Data.Text (toUpper)
import Data.Text.Encoding (decodeUtf8)

dispatch :: Application         -- ^ Default 'Application' (likely 404)
         -> [Route Application] -- ^ Routes
         -> Application
dispatch defaultApp routes env = app env
	where
	app = fromMaybe defaultApp (toDispatch routes routeOn)
	routeOn = (toUpper $ decodeUtf8 $ requestMethod env):(pathInfo env)
