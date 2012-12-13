package verifier;

import java.io.StringReader;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Timer;
import java.util.TimerTask;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.newdawn.slick.AppGameContainer;
import org.newdawn.slick.BasicGame;
import org.newdawn.slick.SlickException;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

/**
 * Verifies a log of a playthrough of a game by playing through it again with 
 * identical inputs at identical times
 *
 */
public class GameVerifier {
	private Timer t = new Timer();
	private LinkedList<InputEvent> tasks = new LinkedList<InputEvent>();
	private ScoreCheckableGame game;
	private final int allegedScore;
	private final long finishTime;

	/**
	 * Read the XML score posting to initialize the verifier.
	 * 
	 * @param posting
	 *            - the score posting sent to the server
	 * @param game
	 *            - the game to play to verify the score
	 */
	public GameVerifier(String posting, final ScoreCheckableGame game) {
		System.out.println("posting is " + posting);
		this.game = game;
		Document xml = null;
		try {
			DocumentBuilder builder = DocumentBuilderFactory.newInstance()
					.newDocumentBuilder();
			xml = builder.parse(new InputSource(new StringReader(posting)));
		} catch (Exception e) {
			e.printStackTrace();
		}

		Node scoreNode = xml.getElementsByTagName("Score").item(0);
		allegedScore = Integer.parseInt(scoreNode.getAttributes()
				.getNamedItem("value").getTextContent());

		NodeList entries = xml.getElementsByTagName("Method");
		long time = 0;
		for (int i = 0; i < entries.getLength(); i++) {
			NodeList attributes = entries.item(i).getChildNodes();
			String methodName = attributes.item(0).getTextContent();
			time = Long.parseLong(attributes.item(1).getTextContent());
			ArrayList<String> params = new ArrayList<String>();
			for (int j = 2; j < attributes.getLength(); j++) {
				params.add(attributes.item(j).getTextContent());
			}
			tasks.add(new InputEvent(time, makeMethodCall(game,
					MethodName.valueOf(methodName), params)));
		}
		finishTime = time;
	}

	/**
	 * Verify the claimed score. Prints "Fully Verified!" if score matches
	 * claimed, "Suspicious!" otherwise. Then exits.
	 * 
	 * @throws SlickException
	 */
	public void startVerification() throws SlickException {
		final AppGameContainer container = new AppGameContainer(game);
		container.setAlwaysRender(false);
		for (InputEvent e : tasks) {
			t.schedule(e.event, e.time);
		}
		t.schedule(new TimerTask() {
			public void run() {
				if (game.getScore() == allegedScore) {
					System.out.println("Fully Verified!");
				} else {
					System.out.println("Suspicious!");
				}
				System.exit(0);
			}
		}, finishTime + 1000);
		container.start();
	}

	/**
	 * The possible methods that handle input in a Slick BasicGame
	 */
	public enum MethodName {
		CONTROLLER_BUTTON_PRESSED, CONTROLLER_BUTTON_RELEASED, CONTROLLER_DOWN_PRESSED, CONTROLLER_DOWN_RELEASED, CONTROLLER_LEFT_PRESSED, CONTROLLER_LEFT_RELEASED, CONTROLLER_RIGHT_PRESSED, CONTROLLER_RIGHT_RELEASED, CONTROLLER_UP_PRESSED, CONTROLLER_UP_RELEASED, KEY_PRESSED, KEY_RELEASED, MOUSE_CLICKED, MOUSE_DRAGGED, MOUSE_MOVED, MOUSE_PRESSED, MOUSE_RELEASED, MOUSE_WHEEL_MOVED
	}

	/**
	 * Creates a callback that'll call the game's specified input-handling
	 * method with the specified arguments
	 * 
	 * @param game
	 *            - the game to pass the input to
	 * @param name
	 *            - the name of the method
	 * @param args
	 *            - the arguments to the method (all strings; this'll cast
	 *            appropriately)
	 * @return - a callback that does the specified input event
	 */
	private static TimerTask makeMethodCall(final BasicGame game,
			MethodName name, final ArrayList<String> args) {
		switch (name) {
		case CONTROLLER_BUTTON_PRESSED:
			return new TimerTask() {
				public void run() {
					game.controllerButtonPressed(Integer.parseInt(args.get(0)),
							Integer.parseInt(args.get(1)));
				}
			};
		case CONTROLLER_BUTTON_RELEASED:
			return new TimerTask() {
				public void run() {
					game.controllerButtonReleased(
							Integer.parseInt(args.get(0)),
							Integer.parseInt(args.get(1)));
				}
			};
		case CONTROLLER_DOWN_PRESSED:
			return new TimerTask() {
				public void run() {
					game.controllerDownPressed(Integer.parseInt(args.get(0)));
				}
			};
		case CONTROLLER_DOWN_RELEASED:
			return new TimerTask() {
				public void run() {
					game.controllerDownReleased(Integer.parseInt(args.get(0)));
				}
			};
		case CONTROLLER_LEFT_PRESSED:
			return new TimerTask() {
				public void run() {
					game.controllerLeftPressed(Integer.parseInt(args.get(0)));
				}
			};
		case CONTROLLER_LEFT_RELEASED:
			return new TimerTask() {
				public void run() {
					game.controllerLeftReleased(Integer.parseInt(args.get(0)));
				}
			};
		case CONTROLLER_RIGHT_PRESSED:
			return new TimerTask() {
				public void run() {
					game.controllerRightPressed(Integer.parseInt(args.get(0)));
				}
			};
		case CONTROLLER_RIGHT_RELEASED:
			return new TimerTask() {
				public void run() {
					game.controllerRightReleased(Integer.parseInt(args.get(0)));
				}
			};
		case CONTROLLER_UP_PRESSED:
			return new TimerTask() {
				public void run() {
					game.controllerUpPressed(Integer.parseInt(args.get(0)));
				}
			};
		case CONTROLLER_UP_RELEASED:
			return new TimerTask() {
				public void run() {
					game.controllerUpReleased(Integer.parseInt(args.get(0)));
				}
			};
		case KEY_PRESSED:
			return new TimerTask() {
				public void run() {
					game.keyPressed(Integer.parseInt(args.get(0)), args.get(1)
							.charAt(0));
				}
			};
		case KEY_RELEASED:
			return new TimerTask() {
				public void run() {
					game.keyReleased(Integer.parseInt(args.get(0)), args.get(1)
							.charAt(0));
				}
			};
		case MOUSE_CLICKED:
			return new TimerTask() {
				public void run() {
					game.mouseClicked(Integer.parseInt(args.get(0)),
							Integer.parseInt(args.get(1)),
							Integer.parseInt(args.get(2)),
							Integer.parseInt(args.get(3)));
				}
			};
		case MOUSE_DRAGGED:
			return new TimerTask() {
				public void run() {
					game.mouseDragged(Integer.parseInt(args.get(0)),
							Integer.parseInt(args.get(1)),
							Integer.parseInt(args.get(2)),
							Integer.parseInt(args.get(3)));
				}
			};
		case MOUSE_MOVED:
			return new TimerTask() {
				public void run() {
					game.mouseMoved(Integer.parseInt(args.get(0)),
							Integer.parseInt(args.get(1)),
							Integer.parseInt(args.get(2)),
							Integer.parseInt(args.get(3)));
				}
			};
		case MOUSE_PRESSED:
			return new TimerTask() {
				public void run() {
					game.mousePressed(Integer.parseInt(args.get(0)),
							Integer.parseInt(args.get(1)),
							Integer.parseInt(args.get(2)));
				}
			};
		case MOUSE_RELEASED:
			return new TimerTask() {
				public void run() {
					game.mouseReleased(Integer.parseInt(args.get(0)),
							Integer.parseInt(args.get(1)),
							Integer.parseInt(args.get(2)));
				}
			};
		case MOUSE_WHEEL_MOVED:
			return new TimerTask() {
				public void run() {
					game.mouseWheelMoved(Integer.parseInt(args.get(0)));
				}
			};
		}
		return null;
	}

	/**
	 * Wrapper for an input event to be sent; stores the time to call it and the callback
	 */
	private static class InputEvent {
		private final long time;
		private final TimerTask event;

		private InputEvent(long t, TimerTask e) {
			time = t;
			event = e;
		}
	}

	public static void main(String[] args) {
		// Read a score posting from the server
		String posting = System.getenv("POSTING");
		
		if(posting == null) {
			System.out.println("Score posting not found.  Treating this as a test run.");
			posting = "<ScorePosting><Game id=\"TestSlickVerifier\"/><User name=\"bitdiddle\" token=\"blah\"/><Score value=\"9001\"/><Log><Method><name>KEY_PRESSED</name><time>1405</time><key>45</key><c>x</c></Method></Log></ScorePosting>";
		}
		
		// Parse the posting
		GameVerifier v = new GameVerifier(posting, new ExampleGame(false));

		// An example valid score posting
		//GameVerifier v = new GameVerifier("<ScorePosting><Game id=\"TestSlickVerifier\"/><User name=\"bitdiddle\" token=\"blah\"/><Score value=\"9001\"/><Log><Method><name>KEY_PRESSED</name><time>1405</time><key>45</key><c>x</c></Method></Log></ScorePosting>", new ExampleGame(false));

		// An example invalid score posting
		// GameVerifier v = new GameVerifier("<ScorePosting><Game id=\"TestSlickVerifier\"/><User name=\"bitdiddle\" token=\"blah\"/><Score value=\"20945209\"/><Log><Method><name>KEY_PRESSED</name><time>1405</time><key>45</key><c>x</c></Method></Log></ScorePosting>", new ExampleGame(false));
	
		// Verify the score
		try {
			v.startVerification();
		} catch (SlickException e) {
			System.out.println("Could not verify");
		}
	}
}
