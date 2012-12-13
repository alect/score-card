package verifier;

import java.io.IOException;
import java.net.Socket;

import com.google.common.base.Stopwatch;

/**
 * Writes XML logs of the input events a game handles, together with timestamps.
 * A game using this class to record its inputs should call log() whenever
 * handling an input event.
 */
public class GameLogger {

	private StringBuilder record;
	private Stopwatch timer;

	protected static String gameName = "TestSlickVerifier";
	protected static String userName = "bitdiddle";
	protected static String userToken = "blah";
	
	public GameLogger() {
		timer = new Stopwatch();
		record = new StringBuilder();
		record.append("<Log>\n");
	}

	/**
	 * Start counting. Should be called when the game starts or unpauses.
	 */
	public void start() {
		timer.start();
	}

	/**
	 * Stop counting. Should be called when the game pauses.
	 */
	public void stop() {
		timer.stop();
	}

	/**
	 * Records an input method that the game handled and its input parameters.
	 * Also makes note of the time when it was called.
	 * 
	 * @param methodName
	 *            - the name of the method
	 * @param p1, p2, p3, p4 
	 *            - the parameters to the input method; can be null
	 *              if there are fewer than 4
	 */
	public void log(GameVerifier.MethodName methodName, Parameter p1,
			Parameter p2, Parameter p3, Parameter p4) {
		record.append("<Method>");
		record.append("<name>" + methodName.toString() + "</name>");
		record.append("<time>" + timer.elapsedMillis() + "</time>");
		if (p1 != null)
			record.append("<" + p1.name + ">" + p1.value + "</" + p1.name
					+ ">");
		if (p2 != null)
			record.append("<" + p2.name + ">" + p2.value + "</" + p2.name
					+ ">");
		if (p3 != null)
			record.append("<" + p3.name + ">" + p3.value + "</" + p3.name
					+ ">");
		if (p4 != null)
			record.append("<" + p4.name + ">" + p4.value + "</" + p4.name
					+ ">");
		record.append("</Method>\n");
	}

	public void log(GameVerifier.MethodName methodName, Parameter p1) {
		log(methodName, p1, null, null, null);
	}

	public void log(GameVerifier.MethodName methodName, Parameter p1,
			Parameter p2) {
		log(methodName, p1, p2, null, null);
	}

	public void log(GameVerifier.MethodName methodName, Parameter p1,
			Parameter p2, Parameter p3) {
		log(methodName, p1, p2, p3, null);
	}

	/**
	 * Post a score to the server, along with the log of inputs handled.
	 * @param claimedScore - the score the game claims to have earned
	 */
	public void post(int claimedScore) throws IOException {
		record.append("</Log>\n");
		String message = "<ScorePosting>\n"
				+ "<Game id=\"" + gameName + "\"/>\n"
				+ "<User name=\"" + userName + "\" token=\"" + userToken + "\"/>\n";
		
		message += "<Score value=\"" + claimedScore + "\"/>\n";
				
		message += record.toString() + "</ScorePosting>";
		
		System.out.println(message);
		
		Socket s = new Socket("ec2-23-20-243-120.compute-1.amazonaws.com", 50000);
		s.getOutputStream().write(message.getBytes());
		s.getOutputStream().flush();
		s.close();
	}

	public static class Parameter {
		public final String name;
		public final String value;

		public Parameter(String n, String v) {
			this.name = n;
			this.value = v;
		}
	}
}
