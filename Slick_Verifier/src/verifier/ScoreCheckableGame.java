package verifier;

import org.newdawn.slick.BasicGame;

/**
 * Small extension of Slick's BasicGame class that adds a score-getting interface.
 */
public abstract class ScoreCheckableGame extends BasicGame {

	public ScoreCheckableGame(String title) {
		super(title);
	}

	// Return the current score of the game
	public abstract int getScore();
}
