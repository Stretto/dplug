module dplug.gui.graphics;

import ae.utils.graphics;
import dplug.plugin.client;
import dplug.plugin.graphics;

import dplug.gui.window;
import dplug.gui.toolkit.context;
import dplug.gui.toolkit.renderer;
import dplug.gui.toolkit.element;

// This is the interface between a plugin client and a IWindow.
// GUIGraphics is a bridge between a plugin client and a IWindow
// It also dispatch window events to the _mainPanel root UI element (you shall add to it to create an UI).
class GUIGraphics : Graphics, IWindowListener
{
    this(Client client, int width, int height)
    {
        super(client);

        _window = null;
        _askedWidth = width;
        _askedHeight = height;

        // The UI is independent of the Window, and is reused
        _uiContext = new UIContext(new UIRenderer, null);
        _mainPanel = new UIElement(_uiContext);
    }

    // Graphics implementation


    override void openUI(void* parentInfo)
    {
        // create window (TODO: cache this? Might not be useful)
        _window = createWindow(parentInfo, this, _askedWidth, _askedHeight);
        _mainPanel.reflow(box2i(0, 0, _askedWidth, _askedHeight));        
    }

    override void closeUI()
    {
        // release window
        _window.terminate();
    }

    // IWindowListener

    override void onMouseClick(int x, int y, MouseButton mb, bool isDoubleClick)
    {
        _mainPanel.mouseClick(x, y, mb, isDoubleClick);
    }

    override void onMouseRelease(int x, int y, MouseButton mb)
    {
        _mainPanel.mouseRelease(x, y, mb);
    }

    override void onMouseWheel(int x, int y, int wheelDeltaX, int wheelDeltaY)
    {
        _mainPanel.mouseWheel(x, y, wheelDeltaX, wheelDeltaY);
    }

    override void onMouseMove(int x, int y, int dx, int dy)
    {
        _mainPanel.mouseMove(x, y, dx, dy);
    }

    override void onKeyDown(int x, int y, Key key)
    {
        // TODO: support key events in UI elements
    }

    override void onKeyUp(int x, int y, Key up)
    {
        // TODO: support key events in UI elements
    }

    // an image you have to draw to, or return that nothing has changed
    void onDraw(ImageRef!RGBA wfb, out bool needRedraw)
    {
        _uiContext.renderer.setFrameBuffer(wfb);
        int disp = 0;

        for (int j = 0; j < wfb.h; ++j)
        {
            RGBA[] scanline = wfb.scanline(j);
            for (int i = 0; i < wfb.w; ++i)
            {
                scanline[i] = RGBA( (i+disp*2) & 255, (j+disp) & 255, 0, 255);
            }
        }
        needRedraw = true;
    }

protected:
    Client _client;
    UIContext _uiContext;
    UIElement _mainPanel;
    IWindow _window;
    int _askedWidth = 0;
    int _askedHeight = 0;
}