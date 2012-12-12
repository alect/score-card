package verifier;

import java.io.IOException;

import org.newdawn.slick.AppGameContainer;
import org.newdawn.slick.GameContainer;
import org.newdawn.slick.Graphics;
import org.newdawn.slick.SlickException;

import verifier.GameLogger.Parameter;

/**
 * A simple game that uses the Slick logger and verifier.  In this game
 * you win (earning 9001 points) if you press x.  You earn 0 points for all
 * other actions.
 */
public class ExampleGame extends ScoreCheckableGame {
	private GameLogger g = new GameLogger();
	private boolean won = false;
	private boolean submitted = false;
	private final boolean playMode;

	public ExampleGame(boolean mode) {
		super("An Easy Game");
		playMode = mode;
	}

	@Override
	public void render(GameContainer gc, Graphics graphics)
			throws SlickException {
		if (playMode) { // don't render if verifying
			if (won) {
				graphics.drawString("You win!", 390, 300);
			} else {
				graphics.drawString("Press x to win!", 350, 300);
			}
		}
	}

	@Override
	public void init(GameContainer arg0) throws SlickException {
		if (playMode) { // don't log if verifying
			g.start();
		}
	}

	@Override
	public void update(GameContainer arg0, int arg1) throws SlickException {
		if (playMode && won && !submitted) {
			submitted = true;
			try {
				g.post(getScore());
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	@Override
	public int getScore() {
		if (won) {
			return 9001;
		} else {
			return 0;
		}
	}
	
	public void keyPressed(int key, char c) {
		if (playMode) { // don't log if verifying
			g.log(GameVerifier.MethodName.KEY_PRESSED, new Parameter("key",
					Integer.toString(key)),
					new Parameter("c", Character.toString(c)));
		}

		if (c == 'x') {
			won = true;
		}
	}

	public static void main(String[] args) throws SlickException {
		AppGameContainer app = new AppGameContainer(new ExampleGame(true));
		app.setDisplayMode(800, 600, false);
		app.start();
	}
}
