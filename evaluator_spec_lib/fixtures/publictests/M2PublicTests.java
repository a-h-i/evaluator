package publictests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.awt.Point;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collections;

import model.game.Cell;
import model.game.Direction;
import model.game.Game;
import model.game.Player;
import model.pieces.Piece;
import model.pieces.heroes.ActivatablePowerHero;
import model.pieces.heroes.Armored;
import model.pieces.heroes.Hero;
import model.pieces.heroes.Medic;
import model.pieces.heroes.Ranged;
import model.pieces.heroes.Speedster;
import model.pieces.heroes.Super;
import model.pieces.heroes.Tech;
import model.pieces.sidekicks.SideKick;
import model.pieces.sidekicks.SideKickP1;
import model.pieces.sidekicks.SideKickP2;

import org.hamcrest.CoreMatchers;
import org.junit.Test;

import exceptions.InvalidMovementException;
import exceptions.InvalidPowerDirectionException;
import exceptions.InvalidPowerTargetException;
import exceptions.InvalidPowerUseException;
import exceptions.OccupiedCellException;
import exceptions.PowerAlreadyUsedException;
import exceptions.UnallowedMovementException;
import exceptions.WrongTurnException;

@SuppressWarnings({ "rawtypes", "unchecked" })
public class M2PublicTests {

	static final String medicPath = "model.pieces.heroes.Medic";
	static final String heroPath = "model.pieces.heroes.Hero";
	static final String activeHeroPath = "model.pieces.heroes.ActivatablePowerHero";
	static final String nonActiveHeroPath = "model.pieces.heroes.NonActivatablePowerHero";
	static final String armoredPath = "model.pieces.heroes.Armored";
	static final String rangedPath = "model.pieces.heroes.Ranged";
	static final String speedsterPath = "model.pieces.heroes.Speedster";
	static final String superPath = "model.pieces.heroes.Super";
	static final String techPath = "model.pieces.heroes.Tech";
	static final String sideKickPath = "model.pieces.sidekicks.SideKick";
	static final String sideKick1Path = "model.pieces.sidekicks.SideKickP1";
	static final String sideKick2Path = "model.pieces.sidekicks.SideKickP2";
	static final String piecePath = "model.pieces.Piece";
	static final String directionPath = "model.game.Direction";
	static final String gamePath = "model.game.Game";
	static final String playerPath = "model.game.Player";

	static final int boardHeight = 7;
	static final int boardWidth = 6;
	static boolean attackCalled;
	static boolean switchTurnsCalled;
	static boolean assemblePiecesCalled;
	static Piece attackedPiece1;

	static Piece attackedPiece2;
	private static boolean attackMethodCalled = false;
	private static boolean switchCalled = false;
	private static boolean winCalled = false;

	private static Piece target = null;
	static final int testMoveRepetitions = 5;

	@Test(timeout = 3000)
	public void testActivatablePowerHeroUsePower() throws Exception {

		testExistsInClass(Class.forName(activeHeroPath), "usePower", true,
				void.class, Class.forName(directionPath),
				Class.forName(piecePath), Point.class);
		testExistsInClass(Class.forName(heroPath), "usePower", false,
				void.class, Class.forName(directionPath),
				Class.forName(piecePath), Point.class);
		testExistsInClass(Class.forName(nonActiveHeroPath), "usePower", false,
				void.class, Class.forName(directionPath),
				Class.forName(piecePath), Point.class);

	}

	@Test(timeout = 3000)
	public void testAttackArmoredWithArmorDownRemovedFromTheBoard()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(7);
		attackAndCheck("SRMPTKA", "A", true, true, false, createGame(0), checks);

		attackAndCheck("SRMPTKA", "A", false, true, false, createGame(0),
				checks);

	}

	@Test(timeout = 3000)
	public void testAttackArmoredWithArmorUpDoesnotGetRemovedFromTheBoard()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(6);
		attackAndCheck("SRMPTKA", "A", true, true, true, createGame(0), checks);

		attackAndCheck("SRMPTKA", "A", false, true, true, createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testAttackArmoredWithArmorUpMethodDoesntCallCheckWinner()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(2);
		attackAndCheck("SRMPTKA", "A", true, true, true, createGame(2), checks);

		attackAndCheck("SRMPTKA", "A", false, true, true, createGame(2), checks);

	}

	@Test(timeout = 3000)
	public void testAttackCallsCheckWinner() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(1);
		attackAndCheck("SRMPTKA", "SRMPTKA", true, true, false, createGame(2),
				checks);

		attackAndCheck("SRMPTKA", "SRMPTKA", false, true, false, createGame(2),
				checks);

	}

	@Test(timeout = 3000)
	public void testAttackEliminatesFirstSideKick() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(9);
		Game g = createGame(0);
		attackAndCheck("SRMPTKA", "K", true, true, false, g, checks);

		attackAndCheck("SRMPTKA", "K", false, true, false, createGame(0),
				checks);

	}

	@Test(timeout = 3000)
	public void testAttackEliminatesSecondSideKick() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(10);
		Game g = createGame(0);
		attackAndCheck("SRMPTKA", "K", true, true, false, g, checks);

		attackAndCheck("SRMPTKA", "K", false, true, false, createGame(0),
				checks);

	}

	@Test(timeout = 3000)
	public void testConstructorGameAssemblePieces() throws Exception {

		assemblePiecesCalled = false;
		Player p1 = new Player("P1");
		Player p2 = new Player("P2");
		new Game(p1, p2) {

			public void assemblePieces() {
				assemblePiecesCalled = true;
			}

		};
		assertTrue(
				"When creating a new game, the pieces should be assembled using the assemblePieces method.",
				assemblePiecesCalled);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePieces() throws Exception {

		testExistsInClass(Game.class, "assemblePieces", true, void.class);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicHeroesP1() throws Exception {

		testAssemblePiecesHelper(1, "heroes", true);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicHeroesP1Postition() throws Exception {

		testAssemblePiecesHelper(1, "heroes", false);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicHeroesP1Random() throws Exception {

		testAssemblePiecesHelper(1, "random", false);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicHeroesP1Type() throws Exception {

		testAssemblePiecesHelper(1, "type", false);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicHeroesP2() throws Exception {

		testAssemblePiecesHelper(2, "heroes", true);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicHeroesP2Position() throws Exception {

		testAssemblePiecesHelper(2, "heroes", false);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicHeroesP2Random() throws Exception {

		testAssemblePiecesHelper(2, "random", false);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicHeroesP2Type() throws Exception {

		testAssemblePiecesHelper(2, "type", false);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicPieceGameP1() throws Exception {

		testAssemblePiecesHelper(1, "game", false);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicPiecePosP2() throws Exception {

		testAssemblePiecesHelper(2, "pos", false);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicSideKickP1() throws Exception {

		testAssemblePiecesHelper(1, "sidekicks", true);

	}

	@Test(timeout = 3000)
	public void testGameAssemblePiecesLogicSideKickP2() throws Exception {

		testAssemblePiecesHelper(2, "sidekicks", true);

	}

	@Test(timeout = 3000)
	public void testGameCheckWinner() throws Exception {

		testExistsInClass(Game.class, "checkWinner", true, boolean.class);

	}

	@Test(timeout = 3000)
	public void testGameCheckWinnerLogic() throws Exception {

		testExistsInClass(Game.class, "checkWinner", true, boolean.class);

		Player p1 = new Player("Player 1");
		Player p2 = new Player("Player 2");
		Game g = new Game(p1, p2);

		Field f = Player.class.getDeclaredField("payloadPos");
		f.setAccessible(true);

		f.set(p1, 5);
		f.set(p2, 0);
		assertEquals(
				"checkWinner should return true only if the current player has won the game.",
				false, g.checkWinner());

		f.set(p1, 6);
		f.set(p2, 0);
		assertEquals(
				"checkWinner should return true whenever the current player has won the game.",
				true, g.checkWinner());

	}

	@Test(timeout = 3000)
	public void testGameGetCellAt() throws Exception {

		testExistsInClass(Game.class, "getCellAt", true, Cell.class, int.class,
				int.class);

	}

	@Test(timeout = 3000)
	public void testGameGetCellAtLogic() throws Exception {

		testExistsInClass(Game.class, "getCellAt", true, Cell.class, int.class,
				int.class);

		Player p1 = new Player("Player 1");
		Player p2 = new Player("Player 2");
		Game g = new Game(p1, p2);

		Field f = Game.class.getDeclaredField("board");
		f.setAccessible(true);
		Cell[][] board = (Cell[][]) f.get(g);

		for (int i = 0; i < board.length; i++) {
			for (int j = 0; j < board[i].length; j++) {
				assertEquals(
						"getCellAt should return the cell located in position [i,j] in the board.",
						board[i][j], g.getCellAt(i, j));
			}
		}

	}

	@Test(timeout = 3000)
	public void testGameSwitchTurns() throws Exception {

		testExistsInClass(Game.class, "switchTurns", true, void.class);

	}

	@Test(timeout = 3000)
	public void testMedicUsePower() throws Exception {

		testExistsInClass(Class.forName(medicPath), "usePower", true,
				void.class, Class.forName(directionPath),
				Class.forName(piecePath), Point.class);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerAlreadyUsed() throws Exception {
		testUsePowerHelper('M', "P", new Point(2, 2), Direction.UP, null, true,
				false);
		testUsePowerHelper('M', "S", new Point(5, 2), Direction.UPLEFT, null,
				true, false);
		testUsePowerHelper('M', "T", new Point(2, 4), Direction.DOWN, null,
				true, false);
		testUsePowerHelper('M', "R", new Point(4, 2), Direction.DOWNRIGHT,
				null, true, false);
		testUsePowerHelper('M', "A", new Point(3, 2), Direction.LEFT, null,
				true, false);
		testUsePowerHelper('M', "M", new Point(1, 4), Direction.RIGHT, null,
				true, false);
		testUsePowerHelper('M', "K", new Point(1, 4), Direction.DOWNLEFT, null,
				true, false);
	}

	@Test(timeout = 3000)
	public void testMedicUsePowerOnEnemy() throws Exception {
		testUsePowerHelper('M', "P", new Point(5, 1), Direction.DOWN, null,
				false, true);
		testUsePowerHelper('M', "S", new Point(5, 2), Direction.UP, null,
				false, true);
		testUsePowerHelper('M', "T", new Point(6, 4), Direction.LEFT, null,
				false, true);
		testUsePowerHelper('M', "R", new Point(4, 2), Direction.RIGHT, null,
				false, true);
		testUsePowerHelper('M', "A", new Point(3, 2), Direction.UPRIGHT, null,
				false, true);
		testUsePowerHelper('M', "M", new Point(1, 2), Direction.UPLEFT, null,
				false, true);
		testUsePowerHelper('M', "K", new Point(5, 1), Direction.DOWNLEFT, null,
				false, true);
	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsActivatableDown() throws Exception {

		testUsePowerHelper('M', "S", new Point(4, 2), Direction.DOWN, null,
				false, false);
		testUsePowerHelper('M', "T", new Point(2, 4), Direction.DOWN, null,
				false, false);
		testUsePowerHelper('M', "R", new Point(4, 2), Direction.DOWN, null,
				false, false);
		testUsePowerHelper('M', "M", new Point(5, 5), Direction.DOWN, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsActivatableDownLeft()
			throws Exception {

		testUsePowerHelper('M', "S", new Point(5, 2), Direction.DOWNLEFT, null,
				false, false);
		testUsePowerHelper('M', "T", new Point(5, 4), Direction.DOWNLEFT, null,
				false, false);
		testUsePowerHelper('M', "R", new Point(4, 2), Direction.DOWNLEFT, null,
				false, false);
		testUsePowerHelper('M', "M", new Point(3, 3), Direction.DOWNLEFT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsActivatableDownRight()
			throws Exception {

		testUsePowerHelper('M', "S", new Point(5, 2), Direction.DOWNRIGHT,
				null, false, false);
		testUsePowerHelper('M', "T", new Point(2, 4), Direction.DOWNRIGHT,
				null, false, false);
		testUsePowerHelper('M', "R", new Point(4, 2), Direction.DOWNRIGHT,
				null, false, false);
		testUsePowerHelper('M', "M", new Point(3, 1), Direction.DOWNRIGHT,
				null, false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsActivatableLeft() throws Exception {

		testUsePowerHelper('M', "S", new Point(5, 2), Direction.LEFT, null,
				false, false);
		testUsePowerHelper('M', "T", new Point(4, 2), Direction.LEFT, null,
				false, false);
		testUsePowerHelper('M', "R", new Point(5, 5), Direction.LEFT, null,
				false, false);
		testUsePowerHelper('M', "M", new Point(1, 1), Direction.LEFT, null,
				false, false);
	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsActivatableRight() throws Exception {

		testUsePowerHelper('M', "S", new Point(5, 2), Direction.RIGHT, null,
				false, false);
		testUsePowerHelper('M', "T", new Point(4, 2), Direction.RIGHT, null,
				false, false);
		testUsePowerHelper('M', "R", new Point(5, 2), Direction.RIGHT, null,
				false, false);
		testUsePowerHelper('M', "M", new Point(1, 4), Direction.RIGHT, null,
				false, false);
	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsActivatableUPRight()
			throws Exception {

		testUsePowerHelper('M', "S", new Point(5, 2), Direction.UPRIGHT, null,
				false, false);
		testUsePowerHelper('M', "T", new Point(6, 4), Direction.UPRIGHT, null,
				false, false);
		testUsePowerHelper('M', "R", new Point(4, 2), Direction.UPRIGHT, null,
				false, false);
		testUsePowerHelper('M', "M", new Point(1, 2), Direction.UPRIGHT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsAlive() throws Exception {
		testUsePowerHelper('M', "PA", new Point(5, 1), Direction.DOWN, null,
				false, false);
		testUsePowerHelper('M', "SA", new Point(5, 2), Direction.UP, null,
				false, false);
		testUsePowerHelper('M', "TA", new Point(6, 4), Direction.LEFT, null,
				false, false);
		testUsePowerHelper('M', "RA", new Point(4, 2), Direction.RIGHT, null,
				false, false);
		testUsePowerHelper('M', "AA", new Point(3, 2), Direction.UPRIGHT, null,
				false, false);
		testUsePowerHelper('M', "MA", new Point(1, 2), Direction.UPLEFT, null,
				false, false);
		testUsePowerHelper('M', "KA", new Point(5, 1), Direction.DOWNLEFT,
				null, false, false);
	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsArmoredDown() throws Exception {

		testUsePowerHelper('M', "A", new Point(3, 2), Direction.DOWN, null,
				false, false);
		testUsePowerHelper('M', "A", new Point(3, 5), Direction.DOWN, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsArmoredDownLeft() throws Exception {

		testUsePowerHelper('M', "A", new Point(3, 2), Direction.DOWNLEFT, null,
				false, false);
		testUsePowerHelper('M', "A", new Point(5, 3), Direction.DOWNLEFT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsArmoredDownRight() throws Exception {

		testUsePowerHelper('M', "A", new Point(3, 2), Direction.DOWNRIGHT,
				null, false, false);
		testUsePowerHelper('M', "A", new Point(2, 4), Direction.DOWNRIGHT,
				null, false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsArmoredUP() throws Exception {

		testUsePowerHelper('M', "A", new Point(3, 2), Direction.UP, null,
				false, false);
		testUsePowerHelper('M', "A", new Point(1, 5), Direction.UP, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsArmoredUPLeft() throws Exception {

		testUsePowerHelper('M', "A", new Point(3, 2), Direction.UPLEFT, null,
				false, false);
		testUsePowerHelper('M', "A", new Point(4, 4), Direction.UPLEFT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsArmoredUPRight() throws Exception {

		testUsePowerHelper('M', "A", new Point(3, 2), Direction.UPRIGHT, null,
				false, false);
		testUsePowerHelper('M', "A", new Point(2, 4), Direction.UPRIGHT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsNonActivatableDownLeft()
			throws Exception {
		testUsePowerHelper('M', "P", new Point(1, 1), Direction.DOWNLEFT, null,
				false, false);
		testUsePowerHelper('K', "P", new Point(5, 3), Direction.DOWNLEFT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsNonActivatableLeft()
			throws Exception {
		testUsePowerHelper('M', "P", new Point(3, 5), Direction.LEFT, null,
				false, false);
		testUsePowerHelper('K', "P", new Point(3, 2), Direction.LEFT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsNonActivatableRight()
			throws Exception {
		testUsePowerHelper('M', "P", new Point(3, 4), Direction.RIGHT, null,
				false, false);
		testUsePowerHelper('K', "P", new Point(1, 2), Direction.RIGHT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsNonActivatableUP() throws Exception {
		testUsePowerHelper('M', "P", new Point(1, 1), Direction.UP, null,
				false, false);
		testUsePowerHelper('M', "K", new Point(3, 1), Direction.UP, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsNonActivatableUPLeft()
			throws Exception {
		testUsePowerHelper('M', "P", new Point(5, 1), Direction.UPLEFT, null,
				false, false);
		testUsePowerHelper('M', "K", new Point(2, 2), Direction.UPLEFT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerResurrectsNonActivatableUPRight()
			throws Exception {
		testUsePowerHelper('M', "P", new Point(6, 4), Direction.UPRIGHT, null,
				false, false);
		testUsePowerHelper('M', "K", new Point(2, 4), Direction.UPRIGHT, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerSwitchesTurn() throws Exception {

		testSwitchTurnHelper('M', "P", new Point(1, 1), Direction.DOWN, null,
				true);
		testSwitchTurnHelper('M', "S", new Point(5, 2), Direction.UP, null,
				true);
		testSwitchTurnHelper('M', "T", new Point(6, 5), Direction.UPRIGHT,
				null, true);
		testSwitchTurnHelper('M', "R", new Point(3, 2), Direction.DOWNLEFT,
				null, true);
		testSwitchTurnHelper('M', "A", new Point(6, 4), Direction.DOWN, null,
				true);
		testSwitchTurnHelper('M', "M", new Point(6, 5), Direction.RIGHT, null,
				true);

	}

	@Test(timeout = 3000)
	public void testMedicUsePowerToOccupiedCell() throws Exception {
		testUsePowerHelper('M', "P", new Point(5, 1), Direction.DOWN,
				new Point(6, 1), false, false);
		testUsePowerHelper('M', "S", new Point(5, 2), Direction.UP, new Point(
				4, 2), false, false);
		testUsePowerHelper('M', "T", new Point(6, 4), Direction.LEFT,
				new Point(6, 3), false, false);
		testUsePowerHelper('M', "R", new Point(4, 2), Direction.RIGHT,
				new Point(4, 3), false, false);
		testUsePowerHelper('M', "A", new Point(3, 2), Direction.UPRIGHT,
				new Point(2, 3), false, false);
		testUsePowerHelper('M', "M", new Point(1, 2), Direction.UPLEFT,
				new Point(0, 1), false, false);
		testUsePowerHelper('M', "K", new Point(5, 1), Direction.DOWNLEFT,
				new Point(6, 0), false, false);
	}

	@Test(timeout = 3000)
	public void testMedicUsePowerWrongTurn() throws Exception {

		testUsePowerWrongTurnHelper('M', "P", new Point(1, 1), Direction.UP,
				null);
		testUsePowerWrongTurnHelper('M', "S", new Point(5, 2), Direction.RIGHT,
				null);
		testUsePowerWrongTurnHelper('M', "T", new Point(2, 4), Direction.LEFT,
				null);
		testUsePowerWrongTurnHelper('M', "R", new Point(4, 2), Direction.DOWN,
				null);
		testUsePowerWrongTurnHelper('M', "A", new Point(3, 2),
				Direction.UPRIGHT, null);
		testUsePowerWrongTurnHelper('M', "M", new Point(1, 4),
				Direction.UPLEFT, null);
		testUsePowerWrongTurnHelper('M', "K", new Point(1, 4),
				Direction.DOWNLEFT, null);
	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToEmptyCellWrongTurnException()
			throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWNLEFT;
			int pointIndex = 0;
			testMovementToEmptyCellWrongTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(techPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(techPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToEnemyCallsAttack() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(1);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, false,
				createGame(0), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, true,
				createGame(0), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.DOWNLEFT, false, true,
				false, createGame(0), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.DOWNLEFT, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToEnemyCallsAttackWithCorrectParameter()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(2);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, false,
				createGame(0), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, true,
				createGame(0), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.DOWNLEFT, false, true,
				false, createGame(0), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.DOWNLEFT, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToEnemyCallsSwitchTurns() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(7);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, false,
				createGame(1), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, true,
				createGame(1), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.DOWNLEFT, false, true,
				false, createGame(1), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.DOWNLEFT, false, true, true,
				createGame(1), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToEnemyCheckPosI() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(5);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToEnemyCheckPosJ() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(6);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToEnemyCorrectlyLocatedOnBoard()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(4);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToEnemyOriginalPositionEmpty() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(3);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNLEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RATK", "SRMPTKA", Direction.DOWNLEFT, false, true,
				false, createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToFriendCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 2, 1,
					boardWidth - 1, 7);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.DOWNLEFT;
			int pointIndex = 0;
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownLeftToFriendCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0, 0, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWNLEFT;
			int pointIndex = 0;
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownLeftWithattackWithoutWrapping() throws Exception {
		moveAndAttack("RAT", "SRMPTK", Direction.DOWNLEFT, true, false, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("RATK", "SRMPTK", Direction.DOWNLEFT, false, false,
				false, createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveDownLeftWithattackWithWrapping() throws Exception {
		moveAndAttack("RAT", "SRMPTK", Direction.DOWNLEFT, true, true, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("RATK", "SRMPTK", Direction.DOWNLEFT, false, true, false,
				createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveDownRightToEmptyCellInvalidMovementException()
			throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 3);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWNRIGHT;
			int pointIndex = 0;
			testInvalidMovementToEmptyCell(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testInvalidMovementToEmptyCell(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testInvalidMovementToEmptyCell(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}
	}

	@Test(timeout = 3000)
	public void testMoveDownRightToEmptyCellSwitchTurn() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWNRIGHT;
			int pointIndex = 0;
			testMovementToEmptyCellSwitchTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(techPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(techPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownRightToEmptyCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 2, 0,
					boardWidth - 2, 7);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.DOWNRIGHT;
			int pointIndex = 0;
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick2Path, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownRightToEmptyCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1,
					boardWidth - 1, boardWidth - 1, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWNRIGHT;
			int pointIndex = 0;
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick2Path, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownRightToEnemyCheckPosI() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(5);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNRIGHT, true, true, false,
				createGame(0), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNRIGHT, false, true,
				false, createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownRightToEnemyCheckPosJ() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(6);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNRIGHT, true, true, false,
				createGame(0), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNRIGHT, false, true,
				false, createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownRightToEnemyCorrectlyLocatedOnBoard()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(4);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNRIGHT, true, true, false,
				createGame(0), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNRIGHT, false, true,
				false, createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownRightToEnemyOriginalPositionEmpty()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(3);
		moveAndAttack("RAT", "SRMPTKA", Direction.DOWNRIGHT, true, true, false,
				createGame(0), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.DOWNRIGHT, false, true,
				false, createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownRightToFriendCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 2, 0,
					boardWidth - 2, 7);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.DOWNRIGHT;
			int pointIndex = 0;
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownRightToFriendCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(boardHeight - 1,
					boardHeight - 1, 0, boardWidth - 1, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWNRIGHT;
			int pointIndex = 0;
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownRightWithattackWithoutWrapping() throws Exception {
		moveAndAttack("RAT", "SRMPTK", Direction.DOWNRIGHT, true, false, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("RATK", "SRMPTK", Direction.DOWNRIGHT, false, false,
				false, createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveDownRightWithattackWithWrapping() throws Exception {
		moveAndAttack("RAT", "SRMPTK", Direction.DOWNRIGHT, true, true, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("RATK", "SRMPTK", Direction.DOWNRIGHT, false, true,
				false, createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveDownToEmptyCellInvalidMovementException()
			throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 2);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWN;
			int pointIndex = 0;
			testInvalidMovementToEmptyCell(techPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testInvalidMovementToEmptyCell(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}
	}

	@Test(timeout = 3000)
	public void testMoveDownToEmptyCellSwitchTurn() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 9);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWN;
			int pointIndex = 0;
			testMovementToEmptyCellSwitchTurn(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(medicPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(superPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownToEmptyCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 2, 0,
					boardWidth - 1, 9);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.DOWN;
			int pointIndex = 0;
			testMovementToEmptyCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick2Path, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownToEmptyCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(boardHeight - 1,
					boardHeight - 1, 0, boardWidth - 1, 9);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWN;
			int pointIndex = 0;
			testMovementToEmptyCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick2Path, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownToEmptyCellWrongTurnException() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 9);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWN;
			int pointIndex = 0;
			testMovementToEmptyCellWrongTurn(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(medicPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(superPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownToEnemyCallsAttack() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(1);
		moveAndAttack("SRMA", "SRMPTKA", Direction.DOWN, true, true, false,
				createGame(0), checks);
		moveAndAttack("SRMA", "SRMPTKA", Direction.DOWN, true, true, true,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.DOWN, false, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.DOWN, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownToEnemyCallsAttackWithCorrectParameter()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(2);
		moveAndAttack("SRMA", "SRMPTKA", Direction.DOWN, true, true, false,
				createGame(0), checks);
		moveAndAttack("SRMA", "SRMPTKA", Direction.DOWN, true, true, true,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.DOWN, false, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.DOWN, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownToEnemyCallsSwitchTurns() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(7);
		moveAndAttack("SRMA", "SRMPTKA", Direction.DOWN, true, true, false,
				createGame(1), checks);
		moveAndAttack("SRMA", "SRMPTKA", Direction.DOWN, true, true, true,
				createGame(1), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.DOWN, false, true, false,
				createGame(1), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.DOWN, false, true, true,
				createGame(1), checks);
	}

	@Test(timeout = 3000)
	public void testMoveDownToFriendCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 2, 0,
					boardWidth - 1, 9);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.DOWN;
			int pointIndex = 0;
			testMovementToFriendCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownToFriendCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(boardHeight - 1,
					boardHeight - 1, 0, boardWidth - 1, 9);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.DOWN;
			int pointIndex = 0;
			testMovementToFriendCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveDownWithattackWithoutWrapping() throws Exception {
		moveAndAttack("SRMA", "SRMPTK", Direction.DOWN, true, false, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("SRMAK", "SRMPTK", Direction.DOWN, false, false, false,
				createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveDownWithattackWithWrapping() throws Exception {
		moveAndAttack("SRMA", "SRMPTK", Direction.DOWN, true, true, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("SRMAK", "SRMPTK", Direction.DOWN, false, true, false,
				createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveLeftToEmptyCellInvalidMovementException()
			throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 10);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.LEFT;
			int pointIndex = 0;
			testInvalidMovementToEmptyCell(techPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveLeftToEmptyCellSwitchTurn() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 10);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.LEFT;
			int pointIndex = 0;
			testMovementToEmptyCellSwitchTurn(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(medicPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(superPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveLeftToEmptyCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 1,
					boardWidth - 1, 10);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.LEFT;
			int pointIndex = 0;
			testMovementToEmptyCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick1Path, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick2Path, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveLeftToEmptyCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0, 0, 10);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.LEFT;
			int pointIndex = 0;
			testMovementToEmptyCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick1Path, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick2Path, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveLeftToEmptyCellWrongTurnException() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 10);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.LEFT;
			int pointIndex = 0;
			testMovementToEmptyCellWrongTurn(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(medicPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(superPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveLeftToEnemyCallsAttack() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(1);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, true, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, true, true, true,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, false, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveLeftToEnemyCallsAttackWithCorrectParameter()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(2);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, true, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, true, true, true,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, false, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveLeftToEnemyCallsSwitchTurns() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(7);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, true, true, false,
				createGame(1), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, true, true, true,
				createGame(1), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, false, true, false,
				createGame(1), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, false, true, true,
				createGame(1), checks);
	}

	@Test(timeout = 3000)
	public void testMoveLeftToEnemyCheckPosI() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(5);
		moveAndAttack("SRMA", "SRMPTKA", Direction.LEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("SRMA", "SRMPTKA", Direction.LEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveLeftToEnemyCheckPosJ() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(6);
		moveAndAttack("SRMA", "SRMPTKA", Direction.LEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("SRMA", "SRMPTKA", Direction.LEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveLeftToEnemyCorrectlyLocatedOnBoard() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(4);
		moveAndAttack("SRMA", "SRMPTKA", Direction.LEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("SRMA", "SRMPTKA", Direction.LEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveLeftToEnemyOriginalPositionEmpty() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(3);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("SRMAK", "SRMPTKA", Direction.LEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveRightToEmptyCellInvalidMovementException()
			throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 1);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.RIGHT;
			int pointIndex = 0;
			testInvalidMovementToEmptyCell(techPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}
	}

	@Test(timeout = 3000)
	public void testMoveRightToEmptyCellSwitchTurn() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 10);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.RIGHT;
			int pointIndex = 0;
			testMovementToEmptyCellSwitchTurn(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(medicPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(superPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveRightToEmptyCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 2, 10);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.RIGHT;
			int pointIndex = 0;
			testMovementToEmptyCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick1Path, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick2Path, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveRightToEmptyCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1,
					boardWidth - 1, boardWidth - 1, 10);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.RIGHT;
			int pointIndex = 0;
			testMovementToEmptyCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick1Path, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick2Path, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveRightToEmptyCellWrongTurnException() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 10);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.RIGHT;
			int pointIndex = 0;
			testMovementToEmptyCellWrongTurn(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(medicPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(superPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveRightToEnemyCallsAttack() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(1);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, true, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, true, true, true,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, false, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveRightToEnemyCallsAttackWithCorrectParameter()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(2);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, true, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, true, true, true,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, false, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveRightToEnemyCallsSwitchTurns() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(7);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, true, true, false,
				createGame(1), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, true, true, true,
				createGame(1), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, false, true, false,
				createGame(1), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, false, true, true,
				createGame(1), checks);
	}

	@Test(timeout = 3000)
	public void testMoveRightToEnemyCheckPosI() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(5);
		moveAndAttack("SRMA", "SRMPTKA", Direction.RIGHT, true, true, false,
				createGame(0), checks);

		moveAndAttack("SRMA", "SRMPTKA", Direction.RIGHT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveRightToEnemyCheckPosJ() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(6);
		moveAndAttack("SRMA", "SRMPTKA", Direction.RIGHT, true, true, false,
				createGame(0), checks);

		moveAndAttack("SRMA", "SRMPTKA", Direction.RIGHT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveRightToEnemyCorrectlyLocatedOnBoard() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(4);
		moveAndAttack("SRMA", "SRMPTKA", Direction.RIGHT, true, true, false,
				createGame(0), checks);

		moveAndAttack("SRMA", "SRMPTKA", Direction.RIGHT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveRightToEnemyOriginalPositionEmpty() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(3);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, true, true, false,
				createGame(0), checks);

		moveAndAttack("SRMAK", "SRMPTKA", Direction.RIGHT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveToArmoredWithArmorDown() throws Exception {
		testValidMoveToArmoredWithArmorDownP1();
		testValidMoveToArmoredWithArmorDownP2();
	}

	@Test(timeout = 3000)
	public void testMoveToArmoredWithArmorDownCorrectlyLocatedOnBoard()
			throws Exception {
		testValidMoveToArmoredWithArmorDownCorrectlyLocatedOnBoardP1();
		testValidMoveToArmoredWithArmorDownCorrectlyLocatedOnBoardP2();

	}

	@Test(timeout = 3000)
	public void testMoveToArmoredWithArmorDownPosIAndJ() throws Exception {
		testValidMoveToArmoredWithArmorDownCheckPosIAndJP1();
		testValidMoveToArmoredWithArmorDownCheckPosIAndJP2();

	}

	@Test(timeout = 3000)
	public void testMoveToArmoredWithArmorUp() throws Exception {
		testValidMoveToArmoredWithArmorUpP1();
		testValidMoveToArmoredWithArmorUpP2();
	}

	@Test(timeout = 3000)
	public void testMoveToArmoredWithArmorUpDidnotGetRemovedFromBoard()
			throws Exception {
		testValidMoveToArmoredWithArmorUpDidnotGetRemovedFromBoardP1();
		testValidMoveToArmoredWithArmorUpDidnotGetRemovedFromBoardP2();

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToEmptyCellInvalidMovementException()
			throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 3);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UPLEFT;
			int pointIndex = 0;
			testInvalidMovementToEmptyCell(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testInvalidMovementToEmptyCell(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testInvalidMovementToEmptyCell(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}
	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToEmptyCellSwitchTurn() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UPLEFT;
			int pointIndex = 0;
			testMovementToEmptyCellSwitchTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(techPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(techPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToEmptyCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(1, boardHeight - 1, 1,
					boardWidth - 1, 7);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.UPLEFT;
			int pointIndex = 0;
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick1Path, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToEmptyCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0, 0, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UPLEFT;
			int pointIndex = 0;
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick1Path, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToEnemyCheckPosI() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(5);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPLEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.UPLEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToEnemyCheckPosJ() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(6);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPLEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.UPLEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToEnemyCorrectlyLocatedOnBoard() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(4);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPLEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.UPLEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToEnemyOriginalPositionEmpty() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(3);
		moveAndAttack("RATK", "SRMPTKA", Direction.UPLEFT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.UPLEFT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToFriendCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(1, boardHeight - 1, 1,
					boardWidth - 1, 7);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.UPLEFT;
			int pointIndex = 0;
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftToFriendCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, 0, 0, boardWidth - 1, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UPLEFT;
			int pointIndex = 0;
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftWithattackWithoutWrapping() throws Exception {
		moveAndAttack("RATK", "SRMPTK", Direction.UPLEFT, true, false, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("RAT", "SRMPTK", Direction.UPLEFT, false, false, false,
				createGame(0), new ArrayList<Integer>());

	}

	@Test(timeout = 3000)
	public void testMoveUpLeftWithattackWithWrapping() throws Exception {
		moveAndAttack("RATK", "SRMPTK", Direction.UPLEFT, true, true, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("RAT", "SRMPTK", Direction.UPLEFT, false, true, false,
				createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveUpRightToEmptyCellWrongTurnException() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UPRIGHT;
			int pointIndex = 0;
			testMovementToEmptyCellWrongTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(techPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(techPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpRightToEnemyCallsAttack() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(1);
		moveAndAttack("RATK", "SRMPTKA", Direction.UPRIGHT, true, true, false,
				createGame(0), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.UPRIGHT, true, true, true,
				createGame(0), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, false,
				createGame(0), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveUpRightToEnemyCallsAttackWithCorrectParameter()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(2);
		moveAndAttack("RATK", "SRMPTKA", Direction.UPRIGHT, true, true, false,
				createGame(0), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.UPRIGHT, true, true, true,
				createGame(0), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, false,
				createGame(0), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveUpRightToEnemyCallsSwitchTurns() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(7);
		moveAndAttack("RATK", "SRMPTKA", Direction.UPRIGHT, true, true, false,
				createGame(1), checks);
		moveAndAttack("RATK", "SRMPTKA", Direction.UPRIGHT, true, true, true,
				createGame(1), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, false,
				createGame(1), checks);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, true,
				createGame(1), checks);
	}

	@Test(timeout = 3000)
	public void testMoveUpRightToEnemyCheckPosI() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(5);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveUpRightToEnemyCheckPosJ() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(6);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveUpRightToEnemyCorrectlyLocatedOnBoard()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(4);
		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveUpRightToEnemyOriginalPositionEmpty() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(3);
		moveAndAttack("RATK", "SRMPTKA", Direction.UPRIGHT, true, true, false,
				createGame(0), checks);

		moveAndAttack("RAT", "SRMPTKA", Direction.UPRIGHT, false, true, false,
				createGame(0), checks);

	}

	@Test(timeout = 3000)
	public void testMoveUpRightToFriendCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(1, boardHeight - 1, 0,
					boardWidth - 2, 7);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.UPRIGHT;
			int pointIndex = 0;
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpRightToFriendCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, 0, 0, boardWidth - 1, 7);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UPRIGHT;
			int pointIndex = 0;
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(techPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpRightWithattackWithoutWrapping() throws Exception {
		moveAndAttack("RATK", "SRMPTK", Direction.UPRIGHT, true, false, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("RAT", "SRMPTK", Direction.UPRIGHT, false, false, false,
				createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveUpRightWithattackWithWrapping() throws Exception {
		moveAndAttack("RATK", "SRMPTK", Direction.UPRIGHT, true, true, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("RAT", "SRMPTK", Direction.UPRIGHT, false, true, false,
				createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveUpToEmptyCellInvalidMovementException()
			throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 2);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UP;
			int pointIndex = 0;
			testInvalidMovementToEmptyCell(techPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testInvalidMovementToEmptyCell(sideKick2Path, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}
	}

	@Test(timeout = 3000)
	public void testMoveUpToEmptyCellSwitchTurn() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 9);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UP;
			int pointIndex = 0;
			testMovementToEmptyCellSwitchTurn(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(medicPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(superPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellSwitchTurn(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpToEmptyCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(1, boardHeight - 1, 0,
					boardWidth - 1, 9);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.UP;
			int pointIndex = 0;
			testMovementToEmptyCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick1Path, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpToEmptyCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, 0, 0, boardWidth - 1, 9);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UP;
			int pointIndex = 0;
			testMovementToEmptyCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToEmptyCell(sideKick1Path, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpToEmptyCellWrongTurnException() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, boardHeight - 1, 0,
					boardWidth - 1, 9);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UP;
			int pointIndex = 0;
			testMovementToEmptyCellWrongTurn(medicPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(superPath, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(medicPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(armoredPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(rangedPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(superPath, 2,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
			testMovementToEmptyCellWrongTurn(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpToEnemyCallsAttack() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(1);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.UP, true, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.UP, true, true, true,
				createGame(0), checks);
		moveAndAttack("SRMA", "SRMPTKA", Direction.UP, false, true, false,
				createGame(0), checks);
		moveAndAttack("SRMA", "SRMPTKA", Direction.UP, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveUpToEnemyCallsAttackWithCorrectParameter()
			throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(2);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.UP, true, true, false,
				createGame(0), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.UP, true, true, true,
				createGame(0), checks);
		moveAndAttack("SRMA", "SRMPTKA", Direction.UP, false, true, false,
				createGame(0), checks);
		moveAndAttack("SRMA", "SRMPTKA", Direction.UP, false, true, true,
				createGame(0), checks);
	}

	@Test(timeout = 3000)
	public void testMoveUpToEnemyCallsSwitchTurns() throws Exception {
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(7);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.UP, true, true, false,
				createGame(1), checks);
		moveAndAttack("SRMAK", "SRMPTKA", Direction.UP, true, true, true,
				createGame(1), checks);
		moveAndAttack("SRMA", "SRMPTKA", Direction.UP, false, true, false,
				createGame(1), checks);
		moveAndAttack("SRMA", "SRMPTKA", Direction.UP, false, true, true,
				createGame(1), checks);
	}

	@Test(timeout = 3000)
	public void testMoveUpToFriendCellWithoutWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(1, boardHeight - 1, 0,
					boardWidth - 1, 9);
			boolean testWrapping = false;
			int testStep = 1;
			Direction testDirection = Direction.UP;
			int pointIndex = 0;
			testMovementToFriendCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test(timeout = 3000)
	public void testMoveUpToFriendCellWithWrapping() throws Exception {

		for (int c = testMoveRepetitions; c > 0; c--) {
			Point[] testPoints = getTestPositions(0, 0, 0, boardWidth - 1, 9);
			boolean testWrapping = true;
			int testStep = 1;
			Direction testDirection = Direction.UP;
			int pointIndex = 0;
			testMovementToFriendCell(medicPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(superPath, 1, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(medicPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(armoredPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(rangedPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(superPath, 2, testPoints[pointIndex++],
					testDirection, testStep, testWrapping);
			testMovementToFriendCell(sideKick1Path, 1,
					testPoints[pointIndex++], testDirection, testStep,
					testWrapping);
		}

	}

	@Test
	public void testMoveUpWithattackWithoutWrapping() throws Exception {

		moveAndAttack("SRMAK", "SRMPTK", Direction.UP, true, false, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("SRMA", "SRMPTK", Direction.UP, false, false, false,
				createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testMoveUpWithattackWithWrapping() throws Exception {

		moveAndAttack("SRMAK", "SRMPTK", Direction.UP, true, true, false,
				createGame(0), new ArrayList<Integer>());
		moveAndAttack("SRMA", "SRMPTK", Direction.UP, false, true, false,
				createGame(0), new ArrayList<Integer>());
	}

	@Test(timeout = 3000)
	public void testRangedUsePower() throws ClassNotFoundException {
		testExistsInClass(Class.forName(rangedPath), "usePower", true,
				void.class, Class.forName(directionPath),
				Class.forName(piecePath), Point.class);
	}

	@Test(timeout = 3000)
	public void testRangedUsePowerDoesNotWrap() throws Exception {
		testUsePowerHelper('R', "P", new Point(0, 0), Direction.UP, new Point(
				6, 0), false, true);
		testUsePowerHelper('R', "S", new Point(0, 2), Direction.UP, new Point(
				6, 2), false, true);
		testUsePowerHelper('R', "T", new Point(6, 3), Direction.DOWN,
				new Point(0, 3), false, true);
		testUsePowerHelper('R', "R", new Point(6, 4), Direction.DOWN,
				new Point(0, 4), false, true);
		testUsePowerHelper('R', "A", new Point(3, 0), Direction.LEFT,
				new Point(3, 5), false, true);
		testUsePowerHelper('R', "M", new Point(1, 5), Direction.RIGHT,
				new Point(1, 0), false, true);
	}

	@Test(timeout = 3000)
	public void testRangedUsePowerDown() throws Exception {
		testUsePowerHelper('R', "P", new Point(1, 1), Direction.DOWN,
				new Point(2, 1), false, true);
		testUsePowerHelper('R', "S", new Point(4, 2), Direction.DOWN,
				new Point(5, 2), false, true);
		testUsePowerHelper('R', "T", new Point(2, 4), Direction.DOWN,
				new Point(3, 4), false, true);
		testUsePowerHelper('R', "R", new Point(4, 2), Direction.DOWN,
				new Point(5, 2), false, true);
		testUsePowerHelper('R', "A", new Point(3, 2), Direction.DOWN,
				new Point(4, 2), false, true);
		testUsePowerHelper('R', "M", new Point(1, 2), Direction.DOWN,
				new Point(5, 2), false, true);
	}

	@Test(timeout = 3000)
	public void testRangedUsePowerInvalidDirection() throws Exception {
		testUsePowerHelper('R', "P", new Point(3, 4), Direction.UPLEFT,
				new Point(3, 5), false, true);
		testUsePowerHelper('R', "S", new Point(5, 2), Direction.UPRIGHT,
				new Point(5, 5), false, true);
		testUsePowerHelper('R', "T", new Point(4, 2), Direction.DOWNLEFT,
				new Point(4, 4), false, true);
		testUsePowerHelper('R', "R", new Point(5, 2), Direction.DOWNRIGHT,
				new Point(5, 3), false, true);

	}

	@Test(timeout = 3000)
	public void testRangedUsePowerOnEmptyCells() throws Exception {
		testUsePowerHelper('R', "P", new Point(1, 1), Direction.UP, new Point(
				0, 5), false, true);
		testUsePowerHelper('R', "S", new Point(5, 2), Direction.UP, new Point(
				3, 5), false, true);
		testUsePowerHelper('R', "T", new Point(2, 4), Direction.DOWN,
				new Point(3, 2), false, true);
		testUsePowerHelper('R', "R", new Point(4, 2), Direction.DOWN,
				new Point(5, 0), false, true);
		testUsePowerHelper('R', "A", new Point(3, 2), Direction.LEFT,
				new Point(5, 5), false, true);
		testUsePowerHelper('R', "M", new Point(1, 4), Direction.RIGHT,
				new Point(0, 2), false, true);
	}

	@Test(timeout = 3000)
	public void testRangedUsePowerRight() throws Exception {
		testUsePowerHelper('R', "P", new Point(3, 4), Direction.RIGHT,
				new Point(3, 5), false, true);
		testUsePowerHelper('R', "S", new Point(5, 2), Direction.RIGHT,
				new Point(5, 5), false, true);
		testUsePowerHelper('R', "T", new Point(4, 2), Direction.RIGHT,
				new Point(4, 4), false, true);
		testUsePowerHelper('R', "R", new Point(5, 2), Direction.RIGHT,
				new Point(5, 3), false, true);
		testUsePowerHelper('R', "A", new Point(3, 2), Direction.RIGHT,
				new Point(3, 5), false, true);
		testUsePowerHelper('R', "M", new Point(1, 4), Direction.RIGHT,
				new Point(1, 5), false, true);
	}

	@Test(timeout = 3000)
	public void testRangedUsePowerSwitchesTurn() throws Exception {

		testSwitchTurnHelper('R', "P", new Point(1, 1), Direction.DOWN,
				new Point(5, 1), true);
		testSwitchTurnHelper('R', "S", new Point(5, 2), Direction.UP,
				new Point(3, 2), true);
		testSwitchTurnHelper('R', "T", new Point(6, 4), Direction.LEFT,
				new Point(6, 0), true);
		testSwitchTurnHelper('R', "R", new Point(4, 2), Direction.RIGHT,
				new Point(4, 5), true);
		testSwitchTurnHelper('R', "A", new Point(3, 2), Direction.RIGHT,
				new Point(3, 5), true);
		testSwitchTurnHelper('R', "M", new Point(1, 2), Direction.RIGHT,
				new Point(1, 5), true);

	}

	@Test(timeout = 3000)
	public void testRangedUsePowerUp() throws Exception {
		testUsePowerHelper('R', "P", new Point(1, 1), Direction.UP, new Point(
				0, 1), false, true);
		testUsePowerHelper('R', "S", new Point(5, 2), Direction.UP, new Point(
				3, 2), false, true);
		testUsePowerHelper('R', "T", new Point(6, 4), Direction.UP, new Point(
				2, 4), false, true);
		testUsePowerHelper('R', "R", new Point(4, 2), Direction.UP, new Point(
				2, 2), false, true);
		testUsePowerHelper('R', "A", new Point(3, 2), Direction.UP, new Point(
				1, 2), false, true);
		testUsePowerHelper('R', "M", new Point(1, 2), Direction.UP, new Point(
				0, 2), false, true);
	}

	@Test(timeout = 3000)
	public void testRangedUsePowerWrongTurn() throws Exception {

		testUsePowerWrongTurnHelper('R', "P", new Point(1, 1), Direction.UP,
				new Point(0, 1));
		testUsePowerWrongTurnHelper('R', "S", new Point(5, 2), Direction.UP,
				new Point(3, 2));
		testUsePowerWrongTurnHelper('R', "T", new Point(2, 4), Direction.DOWN,
				new Point(3, 4));
		testUsePowerWrongTurnHelper('R', "R", new Point(4, 2), Direction.DOWN,
				new Point(5, 2));
		testUsePowerWrongTurnHelper('R', "A", new Point(3, 2), Direction.LEFT,
				new Point(3, 0));
		testUsePowerWrongTurnHelper('R', "M", new Point(1, 4), Direction.RIGHT,
				new Point(1, 5));
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveEliminatesArmoredWrrapping() throws Exception {

		testUsePowerSideKickHelper("AT", 1, new Point(0, 4), Direction.UP,
				true, true, true);
		testUsePowerSideKickHelper("AF", 1, new Point(0, 0), Direction.UPLEFT,
				true, true, true);
		testUsePowerSideKickHelper("AF", 1, new Point(0, 5), Direction.UPRIGHT,
				true, true, true);
		testUsePowerSideKickHelper("AT", 1, new Point(1, 0), Direction.LEFT,
				true, true, true);
		testUsePowerSideKickHelper("AF", 1, new Point(2, 5), Direction.RIGHT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveEliminatesNonActivatableHeroWrrapping()
			throws Exception {
		testUsePowerSideKickHelper("P", 1, new Point(1, 4), Direction.UP, true,
				true, true);
		testUsePowerSideKickHelper("P", 1, new Point(0, 0), Direction.UPLEFT,
				true, true, true);
		testUsePowerSideKickHelper("P", 1, new Point(0, 5), Direction.UPRIGHT,
				true, true, true);
		testUsePowerSideKickHelper("P", 1, new Point(0, 4), Direction.LEFT,
				true, true, true);
		testUsePowerSideKickHelper("P", 1, new Point(2, 5), Direction.RIGHT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveEliminatesSideKickWrapping() throws Exception {
		testUsePowerSideKickHelper("K", 1, new Point(0, 4), Direction.UP, true,
				true, true);
		testUsePowerSideKickHelper("K", 1, new Point(0, 0), Direction.UPLEFT,
				true, true, true);
		testUsePowerSideKickHelper("K", 1, new Point(0, 5), Direction.UPRIGHT,
				true, true, true);
		testUsePowerSideKickHelper("K", 1, new Point(0, 4), Direction.LEFT,
				true, true, true);
		testUsePowerSideKickHelper("K", 1, new Point(2, 5), Direction.RIGHT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveInvalidDirection() throws Exception {
		testUsePowerSideKickHelper("S", 1, new Point(0, 4), Direction.DOWNLEFT,
				true, true, false);
		testUsePowerSideKickHelper("T", 1, new Point(2, 2),
				Direction.DOWNRIGHT, true, true, false);
		testUsePowerSideKickHelper("R", 1, new Point(3, 1), Direction.DOWN,
				true, true, false);
		testUsePowerSideKickHelper("M", 1, new Point(4, 2), Direction.DOWNLEFT,
				true, true, false);
		testUsePowerSideKickHelper("K", 1, new Point(0, 4),
				Direction.DOWNRIGHT, true, true, false);
		testUsePowerSideKickHelper("AT", 1, new Point(2, 5), Direction.DOWN,
				true, true, false);
		testUsePowerSideKickHelper("P", 1, new Point(2, 2), Direction.DOWN,
				true, true, false);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveLeftEliminatesArmored() throws Exception {

		testUsePowerSideKickHelper("AF", 1, new Point(2, 5), Direction.LEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveLeftEliminatesNonActivatablePowerHero()
			throws Exception {

		testUsePowerSideKickHelper("P", 1, new Point(2, 5), Direction.LEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveLeftEliminatesSideKick() throws Exception {

		testUsePowerSideKickHelper("K", 1, new Point(2, 5), Direction.LEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveRightEliminatesActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("S", 1, new Point(0, 4), Direction.RIGHT,
				true, true, true);
		testUsePowerSideKickHelper("T", 1, new Point(2, 4), Direction.RIGHT,
				true, true, true);
		testUsePowerSideKickHelper("R", 1, new Point(3, 1), Direction.RIGHT,
				true, true, true);
		testUsePowerSideKickHelper("M", 1, new Point(0, 0), Direction.RIGHT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveRightEliminatesNonActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("P", 1, new Point(0, 4), Direction.RIGHT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveRightEliminatesSideKick() throws Exception {
		testUsePowerSideKickHelper("K", 1, new Point(0, 4), Direction.RIGHT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveToFriendly() throws Exception {
		testUsePowerSideKickHelper("S", 1, new Point(2, 4), Direction.UP, true,
				false, true);
		testUsePowerSideKickHelper("T", 1, new Point(2, 5), Direction.UPLEFT,
				true, false, true);
		testUsePowerSideKickHelper("R", 1, new Point(3, 1), Direction.UPRIGHT,
				true, false, true);
		testUsePowerSideKickHelper("M", 1, new Point(4, 2), Direction.LEFT,
				true, false, true);
		testUsePowerSideKickHelper("K", 1, new Point(0, 2), Direction.RIGHT,
				true, false, true);
		testUsePowerSideKickHelper("AT", 1, new Point(2, 5), Direction.UP,
				true, false, true);
		testUsePowerSideKickHelper("P", 1, new Point(2, 5), Direction.UP, true,
				false, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpEliminatesActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("S", 1, new Point(3, 4), Direction.UP, true,
				true, true);
		testUsePowerSideKickHelper("T", 1, new Point(2, 5), Direction.UP, true,
				true, true);
		testUsePowerSideKickHelper("R", 1, new Point(3, 1), Direction.UP, true,
				true, true);
		testUsePowerSideKickHelper("M", 1, new Point(4, 0), Direction.UP, true,
				true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpEliminatesArmored() throws Exception {

		testUsePowerSideKickHelper("AF", 1, new Point(4, 0), Direction.UP,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpEliminatesSideKick() throws Exception {

		testUsePowerSideKickHelper("K", 1, new Point(4, 0), Direction.UP, true,
				true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpLeftEliminatesActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("S", 1, new Point(3, 4), Direction.UPLEFT,
				true, true, true);
		testUsePowerSideKickHelper("T", 1, new Point(2, 5), Direction.UPLEFT,
				true, true, true);
		testUsePowerSideKickHelper("R", 1, new Point(3, 1), Direction.UPLEFT,
				true, true, true);
		testUsePowerSideKickHelper("M", 1, new Point(3, 3), Direction.UPLEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpLeftEliminatesArmored() throws Exception {

		testUsePowerSideKickHelper("AT", 1, new Point(2, 2), Direction.UPLEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpLeftEliminatesNonActivatablePowerHero()
			throws Exception {

		testUsePowerSideKickHelper("P", 1, new Point(2, 2), Direction.UPLEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpRightEliminatesActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("S", 1, new Point(2, 4), Direction.UPRIGHT,
				true, true, true);
		testUsePowerSideKickHelper("T", 1, new Point(2, 5), Direction.UPRIGHT,
				true, true, true);
		testUsePowerSideKickHelper("R", 1, new Point(3, 1), Direction.UPRIGHT,
				true, true, true);
		testUsePowerSideKickHelper("M", 1, new Point(3, 5), Direction.UPRIGHT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpRightEliminatesArmored() throws Exception {
		testUsePowerSideKickHelper("AT", 1, new Point(3, 5), Direction.UPRIGHT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpRightEliminatesNonActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("P", 1, new Point(3, 5), Direction.UPRIGHT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP1MoveUpRightEliminatesSideKick() throws Exception {
		testUsePowerSideKickHelper("K", 1, new Point(3, 4), Direction.UPRIGHT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP1WrongTurn() throws Exception {
		testUsePowerSideKickHelper("S", 1, new Point(2, 4), Direction.UP,
				false, true, true);
		testUsePowerSideKickHelper("T", 1, new Point(2, 5), Direction.UPLEFT,
				false, true, true);
		testUsePowerSideKickHelper("R", 1, new Point(3, 1), Direction.UPRIGHT,
				false, true, true);
		testUsePowerSideKickHelper("M", 1, new Point(4, 2), Direction.LEFT,
				false, true, true);
		testUsePowerSideKickHelper("K", 1, new Point(0, 4), Direction.RIGHT,
				false, true, true);
		testUsePowerSideKickHelper("AT", 1, new Point(2, 5), Direction.UP,
				false, true, true);
		testUsePowerSideKickHelper("P", 1, new Point(2, 5), Direction.UP,
				false, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownEliminatesArmored() throws Exception {
		testUsePowerSideKickHelper("AT", 2, new Point(0, 4), Direction.DOWN,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownEliminatesNonActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("P", 2, new Point(0, 4), Direction.DOWN,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownEliminatesSideKick() throws Exception {
		testUsePowerSideKickHelper("K", 2, new Point(0, 4), Direction.DOWN,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownLeftEliminatesActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("S", 2, new Point(0, 4), Direction.DOWNLEFT,
				true, true, true);
		testUsePowerSideKickHelper("T", 2, new Point(2, 5), Direction.DOWNLEFT,
				true, true, true);
		testUsePowerSideKickHelper("R", 2, new Point(3, 1), Direction.DOWNLEFT,
				true, true, true);
		testUsePowerSideKickHelper("M", 2, new Point(0, 4), Direction.DOWNLEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownLeftEliminatesArmored() throws Exception {

		testUsePowerSideKickHelper("AF", 2, new Point(2, 2),
				Direction.DOWNLEFT, true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownLeftEliminatesNonActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("P", 2, new Point(0, 0), Direction.DOWNLEFT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownLeftEliminatesSideKick() throws Exception {

		testUsePowerSideKickHelper("K", 2, new Point(2, 2), Direction.DOWNLEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownRightEliminatesActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("S", 2, new Point(0, 4),
				Direction.DOWNRIGHT, true, true, true);
		testUsePowerSideKickHelper("T", 2, new Point(2, 5),
				Direction.DOWNRIGHT, true, true, true);
		testUsePowerSideKickHelper("R", 2, new Point(3, 1),
				Direction.DOWNRIGHT, true, true, true);
		testUsePowerSideKickHelper("M", 2, new Point(0, 5),
				Direction.DOWNRIGHT, true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownRightEliminatesNonActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("P", 2, new Point(3, 2),
				Direction.DOWNRIGHT, true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveDownRightEliminatesSideKick()
			throws Exception {
		testUsePowerSideKickHelper("K", 2, new Point(3, 5),
				Direction.DOWNRIGHT, true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveEliminatesActivatablePowerHeroWrapping()
			throws Exception {
		testUsePowerSideKickHelper("S", 2, new Point(6, 4), Direction.DOWN,
				true, true, true);
		testUsePowerSideKickHelper("T", 2, new Point(6, 0), Direction.DOWNLEFT,
				true, true, true);
		testUsePowerSideKickHelper("R", 2, new Point(6, 5),
				Direction.DOWNRIGHT, true, true, true);
		testUsePowerSideKickHelper("M", 2, new Point(0, 0), Direction.LEFT,
				true, true, true);
		testUsePowerSideKickHelper("S", 2, new Point(0, 5), Direction.RIGHT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveEliminatesNonActivatablePowerHeroWrapping()
			throws Exception {
		testUsePowerSideKickHelper("P", 2, new Point(6, 0), Direction.DOWN,
				true, true, true);
		testUsePowerSideKickHelper("P", 2, new Point(6, 0), Direction.DOWNLEFT,
				true, true, true);
		testUsePowerSideKickHelper("P", 2, new Point(6, 5),
				Direction.DOWNRIGHT, true, true, true);
		testUsePowerSideKickHelper("P", 2, new Point(0, 0), Direction.LEFT,
				true, true, true);
		testUsePowerSideKickHelper("P", 2, new Point(2, 5), Direction.RIGHT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveEliminatesSideKickWrapping() throws Exception {

		testUsePowerSideKickHelper("K", 2, new Point(6, 0), Direction.DOWN,
				true, true, true);
		testUsePowerSideKickHelper("K", 2, new Point(6, 0), Direction.DOWNLEFT,
				true, true, true);
		testUsePowerSideKickHelper("K", 2, new Point(6, 5),
				Direction.DOWNRIGHT, true, true, true);
		testUsePowerSideKickHelper("K", 2, new Point(0, 0), Direction.LEFT,
				true, true, true);
		testUsePowerSideKickHelper("K", 2, new Point(2, 5), Direction.RIGHT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveLeftEliminatesActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("S", 2, new Point(2, 4), Direction.LEFT,
				true, true, true);
		testUsePowerSideKickHelper("T", 2, new Point(2, 5), Direction.LEFT,
				true, true, true);
		testUsePowerSideKickHelper("R", 2, new Point(3, 1), Direction.LEFT,
				true, true, true);
		testUsePowerSideKickHelper("M", 2, new Point(0, 2), Direction.LEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveLeftEliminatesArmored() throws Exception {

		testUsePowerSideKickHelper("AF", 2, new Point(2, 4), Direction.LEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveLeftEliminatesSideKick() throws Exception {

		testUsePowerSideKickHelper("K", 2, new Point(2, 5), Direction.LEFT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveRightEliminatesActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("S", 2, new Point(0, 4), Direction.RIGHT,
				true, true, true);
		testUsePowerSideKickHelper("T", 2, new Point(2, 2), Direction.RIGHT,
				true, true, true);
		testUsePowerSideKickHelper("R", 2, new Point(3, 1), Direction.RIGHT,
				true, true, true);
		testUsePowerSideKickHelper("M", 2, new Point(0, 0), Direction.RIGHT,
				true, true, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveRightEliminatesArmored() throws Exception {
		testUsePowerSideKickHelper("AT", 2, new Point(0, 4), Direction.RIGHT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveRightEliminatesNonActivatablePowerHero()
			throws Exception {
		testUsePowerSideKickHelper("P", 2, new Point(0, 4), Direction.RIGHT,
				true, true, true);

	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveSwitchesTurn() throws Exception {
		testSwitchTurnHelper('K', "2", new Point(1, 3), Direction.DOWN, null,
				true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2MoveToFriendly() throws Exception {
		testUsePowerSideKickHelper("S", 2, new Point(0, 4), Direction.DOWN,
				true, false, true);
		testUsePowerSideKickHelper("T", 2, new Point(2, 5), Direction.DOWNLEFT,
				true, false, true);
		testUsePowerSideKickHelper("R", 2, new Point(3, 1),
				Direction.DOWNRIGHT, true, false, true);
		testUsePowerSideKickHelper("M", 2, new Point(4, 0), Direction.LEFT,
				true, false, true);
		testUsePowerSideKickHelper("K", 2, new Point(0, 4), Direction.RIGHT,
				true, false, true);
		testUsePowerSideKickHelper("AT", 2, new Point(2, 5), Direction.DOWN,
				true, false, true);
		testUsePowerSideKickHelper("P", 2, new Point(2, 5), Direction.DOWN,
				true, false, true);
	}

	@Test(timeout = 3000)
	public void testSideKickP2WrongTurn() throws Exception {
		testUsePowerSideKickHelper("S", 2, new Point(4, 4), Direction.DOWN,
				false, true, true);
		testUsePowerSideKickHelper("T", 2, new Point(2, 5), Direction.DOWNLEFT,
				false, true, true);
		testUsePowerSideKickHelper("R", 2, new Point(3, 1),
				Direction.DOWNRIGHT, false, true, true);
		testUsePowerSideKickHelper("M", 2, new Point(4, 3), Direction.LEFT,
				false, true, true);
		testUsePowerSideKickHelper("K", 2, new Point(0, 2), Direction.RIGHT,
				false, true, true);
		testUsePowerSideKickHelper("AT", 2, new Point(2, 5), Direction.DOWN,
				false, true, true);
		testUsePowerSideKickHelper("P", 2, new Point(2, 5), Direction.DOWN,
				false, true, true);
	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveDown() throws Exception {

		boolean testWrapping = true;
		int testStep = 2;
		Direction testDirection = Direction.DOWN;

		testMovementToEmptyCell(speedsterPath, 1, new Point(2, 4),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(1, 2),
				testDirection, testStep, testWrapping);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveDownLeft() throws Exception {

		boolean testWrapping = true;
		int testStep = 2;
		Direction testDirection = Direction.DOWNLEFT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(2, 4),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(1, 2),
				testDirection, testStep, testWrapping);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveDownRight() throws Exception {

		boolean testWrapping = true;
		int testStep = 2;
		Direction testDirection = Direction.DOWNRIGHT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(2, 4),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(1, 2),
				testDirection, testStep, testWrapping);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveLeft() throws Exception {

		boolean testWrapping = true;
		int testStep = 2;
		Direction testDirection = Direction.LEFT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(2, 2),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(5, 5),
				testDirection, testStep, testWrapping);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveOverCellToEnemyDown() throws Exception {

		Direction testDirection = Direction.DOWN;

		testUsePowerHelper('P', "EREM", new Point(3, 1), testDirection, null,
				true, true);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveOverCellToEnemyDownRight() throws Exception {

		Direction testDirection = Direction.DOWNRIGHT;

		testUsePowerHelper('P', "ETEM", new Point(3, 0), testDirection, null,
				true, true);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveOverCellToEnemyLeft() throws Exception {

		Direction testDirection = Direction.LEFT;

		testUsePowerHelper('P', "EMEM", new Point(0, 3), testDirection, null,
				true, true);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveOverCellToEnemyRight() throws Exception {

		Direction testDirection = Direction.RIGHT;

		testUsePowerHelper('P', "EKEM", new Point(2, 2), testDirection, null,
				true, true);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveOverCellToEnemyUp() throws Exception {

		Direction testDirection = Direction.UP;

		testUsePowerHelper('P', "ESEM", new Point(6, 0), testDirection, null,
				true, true);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveOverCellToEnemyUpLeft() throws Exception {

		Direction testDirection = Direction.UPLEFT;

		testUsePowerHelper('P', "EMEM", new Point(6, 3), testDirection, null,
				true, true);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveOverCellToEnemyWrapping() throws Exception {
		Direction testDirection = Direction.UP;

		testUsePowerHelper('P', "ETEM", new Point(0, 3), testDirection, null,
				true, true);

		testDirection = Direction.UPLEFT;

		testUsePowerHelper('P', "ESEM", new Point(0, 1), testDirection, null,
				true, true);

		testDirection = Direction.UPRIGHT;

		testUsePowerHelper('P', "EMEM", new Point(0, 5), testDirection, null,
				true, true);

		testDirection = Direction.DOWN;

		testUsePowerHelper('P', "EKEM", new Point(5, 4), testDirection, null,
				true, true);

		testDirection = Direction.DOWNLEFT;

		testUsePowerHelper('P', "EREM", new Point(5, 1), testDirection, null,
				true, true);

		testDirection = Direction.DOWNRIGHT;

		testUsePowerHelper('P', "EREM", new Point(6, 5), testDirection, null,
				true, true);

		testDirection = Direction.LEFT;

		testUsePowerHelper('P', "ESEM", new Point(2, 0), testDirection, null,
				true, true);
		testDirection = Direction.RIGHT;

		testUsePowerHelper('P', "EKEM", new Point(5, 5), testDirection, null,
				true, true);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveRight() throws Exception {

		boolean testWrapping = true;
		int testStep = 2;
		Direction testDirection = Direction.RIGHT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(2, 4),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(5, 2),
				testDirection, testStep, testWrapping);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveSwitchesTurn() throws Exception {

		testSwitchTurnHelper('P', "P", new Point(2, 2), Direction.DOWN, null,
				true);
		testSwitchTurnHelper('P', "S", new Point(5, 2), Direction.UP, null,
				true);
		testSwitchTurnHelper('P', "T", new Point(5, 5), Direction.UPRIGHT,
				null, true);
		testSwitchTurnHelper('P', "R", new Point(3, 2), Direction.DOWNLEFT,
				null, true);
		testSwitchTurnHelper('P', "A", new Point(6, 4), Direction.DOWN, null,
				true);
		testSwitchTurnHelper('P', "M", new Point(6, 5), Direction.RIGHT, null,
				true);
		testSwitchTurnHelper('P', "A", new Point(4, 3), Direction.LEFT, null,
				true);
		testSwitchTurnHelper('P', "M", new Point(0, 0), Direction.DOWNRIGHT,
				null, true);
		testSwitchTurnHelper('P', "R", new Point(3, 2), Direction.UPLEFT, null,
				true);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveToEnemyDown() throws Exception {

		Direction testDirection = Direction.DOWN;

		testUsePowerHelper('P', "ENEM", new Point(3, 1), testDirection, null,
				true, false);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveToEnemyDownLeft() throws Exception {

		Direction testDirection = Direction.DOWNLEFT;

		testUsePowerHelper('P', "ENEM", new Point(3, 3), testDirection, null,
				true, false);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveToEnemyDownRight() throws Exception {

		Direction testDirection = Direction.DOWNRIGHT;

		testUsePowerHelper('P', "ENEM", new Point(3, 0), testDirection, null,
				true, false);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveToEnemyUp() throws Exception {

		Direction testDirection = Direction.UP;

		testUsePowerHelper('P', "ENEM", new Point(6, 0), testDirection, null,
				true, false);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveToEnemyUpLeft() throws Exception {

		Direction testDirection = Direction.UPLEFT;

		testUsePowerHelper('P', "ENEM", new Point(6, 3), testDirection, null,
				true, false);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveToEnemyUpRight() throws Exception {

		Direction testDirection = Direction.UPRIGHT;

		testUsePowerHelper('P', "ENEM", new Point(4, 0), testDirection, null,
				true, false);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveToEnemyWrapping() throws Exception {

		Direction testDirection = Direction.UP;

		testUsePowerHelper('P', "ENEM", new Point(0, 3), testDirection, null,
				true, false);

		testDirection = Direction.UPLEFT;

		testUsePowerHelper('P', "ENEM", new Point(0, 1), testDirection, null,
				true, false);

		testDirection = Direction.UPRIGHT;

		testUsePowerHelper('P', "ENEM", new Point(0, 5), testDirection, null,
				true, false);

		testDirection = Direction.DOWN;

		testUsePowerHelper('P', "ENEM", new Point(5, 4), testDirection, null,
				true, false);

		testDirection = Direction.DOWNLEFT;

		testUsePowerHelper('P', "ENEM", new Point(5, 1), testDirection, null,
				true, false);

		testDirection = Direction.DOWNRIGHT;

		testUsePowerHelper('P', "ENEM", new Point(6, 5), testDirection, null,
				true, false);

		testDirection = Direction.LEFT;

		testUsePowerHelper('P', "ENEM", new Point(2, 0), testDirection, null,
				true, false);

		testDirection = Direction.RIGHT;

		testUsePowerHelper('P', "ENEM", new Point(5, 5), testDirection, null,
				true, false);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveToFriendly() throws Exception {

		Direction testDirection = Direction.RIGHT;

		testUsePowerHelper('P', "EKFM", new Point(2, 2), testDirection, null,
				true, false);

		testDirection = Direction.LEFT;

		testUsePowerHelper('P', "EMFM", new Point(0, 3), testDirection, null,
				true, false);

		testDirection = Direction.DOWNRIGHT;

		testUsePowerHelper('P', "FTFM", new Point(3, 0), testDirection, null,
				true, false);

		testDirection = Direction.DOWNLEFT;

		testUsePowerHelper('P', "ETFM", new Point(3, 3), testDirection, null,
				true, false);

		testDirection = Direction.DOWN;

		testUsePowerHelper('P', "FRFM", new Point(3, 1), testDirection, null,
				true, false);

		testDirection = Direction.UPRIGHT;

		testUsePowerHelper('P', "EKFM", new Point(4, 0), testDirection, null,
				true, false);

		testDirection = Direction.UPLEFT;

		testUsePowerHelper('P', "FMFM", new Point(6, 3), testDirection, null,
				true, false);

		testDirection = Direction.UP;

		testUsePowerHelper('P', "FTFM", new Point(3, 3), testDirection, null,
				true, false);
		testUsePowerHelper('P', "ENFM", new Point(3, 3), testDirection, null,
				true, false);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveToFriendlyWrapping() throws Exception {

		Direction testDirection = Direction.RIGHT;

		testUsePowerHelper('P', "EKFM", new Point(2, 4), testDirection, null,
				true, false);

		testDirection = Direction.LEFT;

		testUsePowerHelper('P', "EMFM", new Point(0, 1), testDirection, null,
				true, false);

		testDirection = Direction.DOWNRIGHT;

		testUsePowerHelper('P', "FTFM", new Point(5, 5), testDirection, null,
				true, false);

		testDirection = Direction.DOWNLEFT;

		testUsePowerHelper('P', "ETFM", new Point(5, 0), testDirection, null,
				true, false);

		testDirection = Direction.DOWN;

		testUsePowerHelper('P', "FRFM", new Point(6, 3), testDirection, null,
				true, false);

		testDirection = Direction.UPRIGHT;

		testUsePowerHelper('P', "EKFM", new Point(0, 5), testDirection, null,
				true, false);

		testDirection = Direction.UPLEFT;

		testUsePowerHelper('P', "FMFM", new Point(1, 0), testDirection, null,
				true, false);

		testDirection = Direction.UP;

		testUsePowerHelper('P', "FSFM", new Point(0, 0), testDirection, null,
				true, false);
	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveUpLeft() throws Exception {

		boolean testWrapping = true;
		int testStep = 2;
		Direction testDirection = Direction.UPLEFT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(2, 4),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(5, 2),
				testDirection, testStep, testWrapping);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveUpRight() throws Exception {

		boolean testWrapping = true;
		int testStep = 2;
		Direction testDirection = Direction.UPRIGHT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(2, 4),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(4, 2),
				testDirection, testStep, testWrapping);

	}

	@Test(timeout = 3000)
	public void testSpeedsterMoveWrapping() throws Exception {

		boolean testWrapping = true;
		int testStep = 2;
		Direction testDirection = Direction.LEFT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(5, 0),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(0, 0),
				testDirection, testStep, testWrapping);

		testDirection = Direction.RIGHT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(5, 5),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(0, 5),
				testDirection, testStep, testWrapping);

		testDirection = Direction.DOWNRIGHT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(6, 4),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(6, 5),
				testDirection, testStep, testWrapping);

		testDirection = Direction.DOWNLEFT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(6, 4),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(6, 0),
				testDirection, testStep, testWrapping);

		testDirection = Direction.DOWN;

		testMovementToEmptyCell(speedsterPath, 1, new Point(6, 4),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(6, 2),
				testDirection, testStep, testWrapping);

		testDirection = Direction.UPRIGHT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(0, 5),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(0, 1),
				testDirection, testStep, testWrapping);

		testDirection = Direction.UPLEFT;

		testMovementToEmptyCell(speedsterPath, 1, new Point(0, 2),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(0, 0),
				testDirection, testStep, testWrapping);

		testDirection = Direction.UP;

		testMovementToEmptyCell(speedsterPath, 1, new Point(0, 2),
				testDirection, testStep, testWrapping);
		testMovementToEmptyCell(speedsterPath, 2, new Point(1, 1),
				testDirection, testStep, testWrapping);
	}

	@Test(timeout = 3000)
	public void testSuperUsePower() throws ClassNotFoundException {
		testExistsInClass(Class.forName(superPath), "usePower", true,
				void.class, Class.forName(directionPath),
				Class.forName(piecePath), Point.class);
	}

	@Test(timeout = 3000)
	public void testSuperUsePowerAlreadyUsed() throws Exception {

		Direction testedDirection = Direction.UP;

		testUsePowerHelper('S', "EPET", new Point(0, 3), testedDirection, null,
				true, true);

		testUsePowerHelper('S', "EAEK", new Point(4, 1), testedDirection, null,
				true, true);

		testedDirection = Direction.DOWN;

		testUsePowerHelper('S', "EAFM", new Point(4, 1), testedDirection, null,
				true, true);

		testUsePowerHelper('S', "ENEP", new Point(3, 3), testedDirection, null,
				true, true);

		testedDirection = Direction.LEFT;

		testUsePowerHelper('S', "ERET", new Point(5, 2), testedDirection, null,
				true, true);

		testUsePowerHelper('S', "EKEK", new Point(1, 2), testedDirection, null,
				true, true);

		testedDirection = Direction.RIGHT;

		testUsePowerHelper('S', "EKFK", new Point(5, 2), testedDirection, null,
				true, true);

		testUsePowerHelper('S', "EMEN", new Point(6, 4), testedDirection, null,
				true, true);

	}

	@Test(timeout = 3000)
	public void testSuperUsePowerDoesNotWrap1() throws Exception {

		Direction testedDirection = Direction.RIGHT;

		testUsePowerHelper('S', "EPET", new Point(0, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ERET", new Point(1, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ETEM", new Point(2, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EPEP", new Point(3, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAEK", new Point(4, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKEK", new Point(5, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEP", new Point(6, 4), testedDirection, null,
				false, true);

		testedDirection = Direction.LEFT;

		testUsePowerHelper('S', "EPET", new Point(0, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ERET", new Point(1, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ETEM", new Point(2, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EPEP", new Point(3, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAEK", new Point(4, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKEK", new Point(5, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEP", new Point(6, 1), testedDirection, null,
				false, true);

		testedDirection = Direction.DOWN;

		testUsePowerHelper('S', "EPET", new Point(5, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ERET", new Point(5, 0), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ETEM", new Point(5, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EPEP", new Point(5, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAEK", new Point(5, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKEK", new Point(5, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEP", new Point(5, 3), testedDirection, null,
				false, true);

		testedDirection = Direction.UP;

		testUsePowerHelper('S', "EPET", new Point(1, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ERET", new Point(1, 0), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ETEM", new Point(1, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EPEP", new Point(1, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAEK", new Point(1, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKEK", new Point(1, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEP", new Point(1, 3), testedDirection, null,
				false, true);

	}

	@Test(timeout = 3000)
	public void testSuperUsePowerInvalidDirection() throws Exception {

		Direction testedDirection = Direction.UPRIGHT;

		testUsePowerHelper('S', "EPET", new Point(0, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ERET", new Point(1, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ETEM", new Point(2, 0), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EPEP", new Point(3, 0), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAEK", new Point(4, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKEK", new Point(5, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEP", new Point(6, 3), testedDirection, null,
				false, true);

		testedDirection = Direction.DOWNRIGHT;

		testUsePowerHelper('S', "EPFT", new Point(6, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FRET", new Point(5, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAFM", new Point(4, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ENEP", new Point(3, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FAEK", new Point(2, 0), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKFK", new Point(1, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEN", new Point(0, 1), testedDirection, null,
				false, true);

		testedDirection = Direction.UPLEFT;

		testUsePowerHelper('S', "EPET", new Point(6, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ERET", new Point(5, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ETEM", new Point(4, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EPEP", new Point(3, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAEK", new Point(2, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKEK", new Point(1, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEP", new Point(0, 4), testedDirection, null,
				false, true);

		testedDirection = Direction.DOWNLEFT;

		testUsePowerHelper('S', "EPFT", new Point(0, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FRET", new Point(1, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAFM", new Point(2, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ENEP", new Point(3, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FAEK", new Point(4, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKFK", new Point(5, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEN", new Point(6, 4), testedDirection, null,
				false, true);

	}

	@Test(timeout = 3000)
	public void testSuperUsePowerOn1EnemyDown() throws Exception {

		Direction testedDirection = Direction.DOWN;

		testUsePowerHelper('S', "EPFT", new Point(3, 0), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FRET", new Point(2, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAFM", new Point(1, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ENEP", new Point(4, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FAEK", new Point(0, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKFK", new Point(2, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEN", new Point(4, 0), testedDirection, null,
				false, true);
	}

	@Test(timeout = 3000)
	public void testSuperUsePowerOn1EnemyLeft() throws Exception {

		Direction testedDirection = Direction.LEFT;

		testUsePowerHelper('S', "EPFT", new Point(0, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FRET", new Point(1, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAFM", new Point(2, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ENEP", new Point(3, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FAEK", new Point(4, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKFK", new Point(5, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEN", new Point(6, 4), testedDirection, null,
				false, true);
	}

	@Test(timeout = 3000)
	public void testSuperUsePowerOn1EnemyRight() throws Exception {

		Direction testedDirection = Direction.RIGHT;

		testUsePowerHelper('S', "EPFT", new Point(6, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FRET", new Point(5, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAFM", new Point(4, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ENEP", new Point(3, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "FAEK", new Point(2, 0), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKFK", new Point(1, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEN", new Point(0, 1), testedDirection, null,
				false, true);
	}

	@Test(timeout = 3000)
	public void testSuperUsePowerOn2EnemiesDown() throws Exception {

		Direction testedDirection = Direction.DOWN;

		testUsePowerHelper('S', "EPET", new Point(3, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ERET", new Point(2, 0), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ETEM", new Point(0, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EPEP", new Point(4, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAEK", new Point(1, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKEK", new Point(2, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEP", new Point(4, 3), testedDirection, null,
				false, true);
	}

	@Test(timeout = 3000)
	public void testSuperUsePowerOn2EnemiesLeft() throws Exception {

		Direction testedDirection = Direction.LEFT;

		testUsePowerHelper('S', "EPET", new Point(6, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ERET", new Point(5, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ETEM", new Point(4, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EPEP", new Point(3, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAEK", new Point(2, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKEK", new Point(1, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEP", new Point(0, 4), testedDirection, null,
				false, true);
	}

	@Test(timeout = 3000)
	public void testSuperUsePowerOn2EnemiesUp() throws Exception {

		Direction testedDirection = Direction.UP;

		testUsePowerHelper('S', "EPET", new Point(3, 3), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ERET", new Point(2, 0), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "ETEM", new Point(5, 1), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EPEP", new Point(4, 2), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EAEK", new Point(6, 4), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EKEK", new Point(2, 5), testedDirection, null,
				false, true);

		testUsePowerHelper('S', "EMEP", new Point(4, 3), testedDirection, null,
				false, true);
	}

	@Test(timeout = 3000)
	public void testSuperUsePowerSwitchesTurn() throws Exception {

		testSwitchTurnHelper('S', "PP", new Point(1, 1), Direction.DOWN, null,
				true);
		testSwitchTurnHelper('S', "SP", new Point(5, 2), Direction.UP, null,
				true);
		testSwitchTurnHelper('S', "AN", new Point(6, 4), Direction.LEFT, null,
				true);
		testSwitchTurnHelper('S', "MS", new Point(4, 2), Direction.RIGHT, null,
				true);

	}

	@Test(timeout = 3000)
	public void testSuperUsePowerWrongTurn() throws Exception {

		Direction testedDirection = Direction.UP;

		testUsePowerHelper('S', "EPET", new Point(0, 3), testedDirection, null,
				false, false);

		testUsePowerHelper('S', "EAEK", new Point(4, 1), testedDirection, null,
				false, false);

		testedDirection = Direction.DOWN;

		testUsePowerHelper('S', "EAFM", new Point(4, 1), testedDirection, null,
				false, false);

		testUsePowerHelper('S', "ENEP", new Point(3, 3), testedDirection, null,
				false, false);

		testedDirection = Direction.LEFT;

		testUsePowerHelper('S', "ERET", new Point(5, 2), testedDirection, null,
				false, false);

		testUsePowerHelper('S', "EKEK", new Point(1, 2), testedDirection, null,
				false, false);

		testedDirection = Direction.RIGHT;

		testUsePowerHelper('S', "EKFK", new Point(5, 2), testedDirection, null,
				false, false);

		testUsePowerHelper('S', "EMEN", new Point(6, 4), testedDirection, null,
				false, false);

	}

	@Test(timeout = 3000)
	public void testTechUsePower() throws ClassNotFoundException {
		testExistsInClass(Class.forName(techPath), "usePower", true,
				void.class, Class.forName(directionPath),
				Class.forName(piecePath), Point.class);
	}

	@Test(timeout = 3000)
	public void testTechUsePowerAlreadyUsed() throws Exception {

		testUsePowerHelper('T', "TFP23", new Point(1, 1), null,
				new Point(4, 3), true, false);
		testUsePowerHelper('T', "TFK32", new Point(6, 4), null,
				new Point(0, 0), true, false);

		testUsePowerHelper('T', "HES22", new Point(4, 2), null, null, true,
				false);
		testUsePowerHelper('T', "HET12", new Point(4, 2), null, null, true,
				false);

		testUsePowerHelper('T', "HEA45", new Point(4, 2), null, null, true,
				false);

		testUsePowerHelper('T', "UFR35", new Point(4, 2), null, null, true,
				false);
		testUsePowerHelper('T', "UFM02", new Point(4, 2), null, null, true,
				false);

		testUsePowerHelper('T', "UFA12", new Point(4, 2), null, null, true,
				false);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerDoesNotSwitchTurn() throws Exception {

		testSwitchTurnHelper('T', "TP23", new Point(1, 1), null,
				new Point(4, 3), false);
		testSwitchTurnHelper('T', "TS00", new Point(5, 2), null,
				new Point(1, 2), false);
		testSwitchTurnHelper('T', "TT02", new Point(6, 4), null,
				new Point(0, 0), false);
		testSwitchTurnHelper('T', "TR24", new Point(4, 2), null,
				new Point(5, 3), false);
		testSwitchTurnHelper('T', "TA32", new Point(6, 4), null,
				new Point(0, 0), false);
		testSwitchTurnHelper('T', "TM22", new Point(4, 2), null,
				new Point(5, 3), false);
		testSwitchTurnHelper('T', "TK32", new Point(6, 4), null,
				new Point(0, 0), false);

		testSwitchTurnHelper('T', "HS22", new Point(4, 2), null, null, false);
		testSwitchTurnHelper('T', "HT12", new Point(4, 2), null, null, false);
		testSwitchTurnHelper('T', "HR25", new Point(4, 2), null, null, false);
		testSwitchTurnHelper('T', "HA45", new Point(4, 2), null, null, false);
		testSwitchTurnHelper('T', "HM20", new Point(4, 2), null, null, false);

		testSwitchTurnHelper('T', "US01", new Point(4, 2), null, null, false);
		testSwitchTurnHelper('T', "UT11", new Point(4, 2), null, null, false);
		testSwitchTurnHelper('T', "UR35", new Point(4, 2), null, null, false);
		testSwitchTurnHelper('T', "UA12", new Point(4, 2), null, null, false);
		testSwitchTurnHelper('T', "UM02", new Point(4, 2), null, null, false);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerHackArmored() throws Exception {

		testUsePowerHelper('T', "HEA45", new Point(4, 2), null, null, false,
				false);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerHackArmoredDown() throws Exception {

		testUsePowerHelper('T', "HEA45", new Point(4, 2), null, null, false,
				true);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerHackPowerUsed() throws Exception {

		testUsePowerHelper('T', "HES22", new Point(4, 2), null, null, false,
				true);
		testUsePowerHelper('T', "HET12", new Point(4, 2), null, null, false,
				true);
		testUsePowerHelper('T', "HER25", new Point(4, 2), null, null, false,
				true);
		testUsePowerHelper('T', "HEM20", new Point(4, 2), null, null, false,
				true);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerRestoreActivatablePowerHero() throws Exception {

		testUsePowerHelper('T', "UFS01", new Point(4, 2), null, null, false,
				false);
		testUsePowerHelper('T', "UFT11", new Point(4, 2), null, null, false,
				false);
		testUsePowerHelper('T', "UFR35", new Point(4, 2), null, null, false,
				false);
		testUsePowerHelper('T', "UFM02", new Point(4, 2), null, null, false,
				false);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerRestorePowerArmoredUp() throws Exception {

		testUsePowerHelper('T', "UFA12", new Point(4, 2), null, null, false,
				true);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerRestorePowerNotUsed() throws Exception {

		testUsePowerHelper('T', "UFS01", new Point(4, 2), null, null, false,
				true);
		testUsePowerHelper('T', "UFT11", new Point(4, 2), null, null, false,
				true);
		testUsePowerHelper('T', "UFR35", new Point(4, 2), null, null, false,
				true);
		testUsePowerHelper('T', "UFM02", new Point(4, 2), null, null, false,
				true);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerTeleport() throws Exception {

		testUsePowerHelper('T', "TFP23", new Point(1, 1), null,
				new Point(4, 3), false, false);
		testUsePowerHelper('T', "TFS00", new Point(5, 2), null,
				new Point(1, 2), false, false);
		testUsePowerHelper('T', "TFT02", new Point(6, 4), null,
				new Point(0, 0), false, false);
		testUsePowerHelper('T', "TFR24", new Point(4, 2), null,
				new Point(5, 3), false, false);
		testUsePowerHelper('T', "TFA32", new Point(6, 4), null,
				new Point(0, 0), false, false);
		testUsePowerHelper('T', "TFM22", new Point(4, 2), null,
				new Point(5, 3), false, false);
		testUsePowerHelper('T', "TFK32", new Point(6, 4), null,
				new Point(0, 0), false, false);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerTeleportToOccupiedCell() throws Exception {

		testUsePowerHelper('T', "TFP23", new Point(1, 1), null,
				new Point(4, 3), false, true);
		testUsePowerHelper('T', "TFS00", new Point(5, 2), null,
				new Point(1, 2), false, true);
		testUsePowerHelper('T', "TFT02", new Point(6, 4), null,
				new Point(0, 0), false, true);
		testUsePowerHelper('T', "TFR24", new Point(4, 2), null,
				new Point(5, 3), false, true);
		testUsePowerHelper('T', "TFA32", new Point(6, 4), null,
				new Point(0, 0), false, true);
		testUsePowerHelper('T', "TFM22", new Point(4, 2), null,
				new Point(5, 3), false, true);
		testUsePowerHelper('T', "TFK32", new Point(6, 4), null,
				new Point(0, 0), false, true);

	}

	@Test(timeout = 3000)
	public void testTechUsePowerWrongTurn() throws Exception {

		testUsePowerHelper('T', "TFS00", new Point(5, 2), Direction.UP,
				new Point(1, 2), false, false);
		testUsePowerHelper('T', "TFR24", new Point(4, 2), Direction.UP,
				new Point(5, 3), false, false);

		testUsePowerHelper('T', "HER25", new Point(4, 2), Direction.UP, null,
				false, false);
		testUsePowerHelper('T', "HEM20", new Point(4, 2), Direction.UP, null,
				false, false);

		testUsePowerHelper('T', "HEA45", new Point(4, 2), Direction.UP, null,
				false, false);

		testUsePowerHelper('T', "UFS01", new Point(4, 2), Direction.UP, null,
				false, false);
		testUsePowerHelper('T', "UFT11", new Point(4, 2), Direction.UP, null,
				false, false);

		testUsePowerHelper('T', "UFA12", new Point(4, 2), Direction.UP, null,
				false, false);

	}

	// Helpers -----

	private void testValidMoveToArmoredWithArmorUpP1() throws Exception {
		String pieces = "";
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)

				pieces = "SRMA";
			else
				pieces = "RAT";
			if (i == 1 || i == 3 || i == 4 || i == 5 || i == 6)
				pieces += "K";
			moveAndAttack(pieces, "A", d, true, true, true, createGame(0),
					new ArrayList<Integer>());
			moveAndAttack(pieces, "A", d, true, false, true, createGame(0),
					new ArrayList<Integer>());

		}
	}

	private void testValidMoveToArmoredWithArmorUpP2() throws Exception {
		String pieces = "";
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)
				pieces = "SRMA";
			else
				pieces = "RAT";
			if (i == 2 || i == 3 || i == 4 || i == 7 || i == 8)
				pieces += "K";
			moveAndAttack(pieces, "A", d, false, true, true, createGame(0),
					new ArrayList<Integer>());
			moveAndAttack(pieces, "A", d, false, false, true, createGame(0),
					new ArrayList<Integer>());

		}
	}

	private void testValidMoveToArmoredWithArmorUpDidnotGetRemovedFromBoardP1()
			throws Exception {
		String pieces = "";
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(8);
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)

				pieces = "SRMA";
			else
				pieces = "RAT";
			if (i == 1 || i == 3 || i == 4 || i == 5 || i == 6)
				pieces += "K";
			moveAndAttack(pieces, "A", d, true, true, true, createGame(0),
					checks);
			moveAndAttack(pieces, "A", d, true, false, true, createGame(0),
					checks);

		}
	}

	private void testValidMoveToArmoredWithArmorUpDidnotGetRemovedFromBoardP2()
			throws Exception {
		String pieces = "";
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(8);
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)
				pieces = "SRMA";
			else
				pieces = "RAT";
			if (i == 2 || i == 3 || i == 4 || i == 7 || i == 8)
				pieces += "K";
			moveAndAttack(pieces, "A", d, false, true, true, createGame(0),
					checks);
			moveAndAttack(pieces, "A", d, false, false, true, createGame(0),
					checks);

		}
	}

	private void testValidMoveToArmoredWithArmorDownP1() throws Exception {
		String pieces = "";
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)
				pieces = "SRMA";
			else
				pieces = "RAT";
			if (i == 1 || i == 3 || i == 4 || i == 5 || i == 6)
				pieces += "K";
			moveAndAttack(pieces, "A", d, true, true, false, createGame(0),
					new ArrayList<Integer>());
			moveAndAttack(pieces, "A", d, true, false, false, createGame(0),
					new ArrayList<Integer>());

		}

	}

	private void testValidMoveToArmoredWithArmorDownP2() throws Exception {
		String pieces = "";
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)
				pieces = "SRMA";
			else
				pieces = "RAT";
			if (i == 2 || i == 3 || i == 4 || i == 7 || i == 8)
				pieces += "K";
			moveAndAttack(pieces, "A", d, false, true, false, createGame(0),
					new ArrayList<Integer>());
			moveAndAttack(pieces, "A", d, false, false, false, createGame(0),
					new ArrayList<Integer>());

		}

	}

	private void testValidMoveToArmoredWithArmorDownCorrectlyLocatedOnBoardP1()
			throws Exception {
		String pieces = "";
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(10);
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)
				pieces = "SRMA";
			else
				pieces = "RAT";

			moveAndAttack(pieces, "A", d, true, true, false, createGame(0),
					checks);
			moveAndAttack(pieces, "A", d, true, false, false, createGame(0),
					checks);

		}

	}

	private void testValidMoveToArmoredWithArmorDownCorrectlyLocatedOnBoardP2()
			throws Exception {
		String pieces = "";
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(10);
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)
				pieces = "SRMA";
			else
				pieces = "RAT";

			moveAndAttack(pieces, "A", d, false, true, false, createGame(0),
					checks);
			moveAndAttack(pieces, "A", d, false, false, false, createGame(0),
					checks);

		}
	}

	private void testValidMoveToArmoredWithArmorDownCheckPosIAndJP1()
			throws Exception {
		String pieces = "";
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(11);
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)
				pieces = "SRMA";
			else
				pieces = "RAT";

			moveAndAttack(pieces, "A", d, true, true, false, createGame(0),
					checks);
			moveAndAttack(pieces, "A", d, true, false, false, createGame(0),
					checks);

		}

	}

	private void testValidMoveToArmoredWithArmorDownCheckPosIAndJP2()
			throws Exception {
		String pieces = "";
		ArrayList<Integer> checks = new ArrayList<Integer>();
		checks.add(11);
		for (int i = 1; i <= 8; i++)

		{
			Direction d = getDirectionFromNumber(i);
			if (i <= 4)
				pieces = "SRMA";
			else
				pieces = "RAT";

			moveAndAttack(pieces, "A", d, false, true, false, createGame(0),
					checks);
			moveAndAttack(pieces, "A", d, false, false, false, createGame(0),
					checks);

		}

	}

	private void testSwitchTurnHelper(char powerUser, String powerTargets,
			Point userLoc, Direction powerDir, Point targetLoc,
			boolean shouldSwitch) throws Exception {

		Game game = createGameForSwitchTurn();
		Player currentPlayer = game.getCurrentPlayer();
		Player enemy = (game.getPlayer1() == currentPlayer ? game.getPlayer2()
				: game.getPlayer1());

		switch (powerUser) {
		case 'P':

			testMovementToEmptyCellHelper(game, speedsterPath, 1, userLoc,
					powerDir, 2, true);

			break;

		case 'S':

			Super s = new Super(currentPlayer, game, "Super");
			Point target1Loc = getFinalDestination(userLoc, powerDir, 1, false);
			Point target2Loc = getFinalDestination(userLoc, powerDir, 2, false);
			game = clearAndInsert(
					game,
					new Object[][] {
							{ userLoc.x, userLoc.y, s },
							{
									target1Loc.x,
									target1Loc.y,
									createPiece(powerTargets.charAt(0), enemy,
											game) },
							{
									target2Loc.x,
									target2Loc.y,
									createPiece(powerTargets.charAt(1), enemy,
											game) } });

			s.usePower(powerDir, null, null);

			break;

		case 'T':

			Tech t = new Tech(currentPlayer, game, "Tech");

			switch (powerTargets.charAt(0)) {
			case 'T':

				Piece targetPiece = createPiece(powerTargets.charAt(1),
						currentPlayer, game);
				Point l = new Point(Integer.parseInt(""
						+ powerTargets.charAt(2)), Integer.parseInt(""
						+ powerTargets.charAt(3)));

				game = clearAndInsert(game,
						new Object[][] { { userLoc.x, userLoc.y, t },
								{ l.x, l.y, targetPiece } });

				t.usePower(powerDir, targetPiece, targetLoc);

				break;

			case 'H':

				targetPiece = createPiece(powerTargets.charAt(1), enemy, game);
				if (targetPiece instanceof ActivatablePowerHero)
					((ActivatablePowerHero) targetPiece).setPowerUsed(false);
				if (targetPiece instanceof Armored)
					((Armored) targetPiece).setArmorUp(true);
				l = new Point(Integer.parseInt("" + powerTargets.charAt(2)),
						Integer.parseInt("" + powerTargets.charAt(3)));

				game = clearAndInsert(game,
						new Object[][] { { userLoc.x, userLoc.y, t },
								{ l.x, l.y, targetPiece } });

				t.usePower(null, targetPiece, null);

				break;

			case 'U':

				targetPiece = createPiece(powerTargets.charAt(1),
						currentPlayer, game);
				if (targetPiece instanceof ActivatablePowerHero)
					((ActivatablePowerHero) targetPiece).setPowerUsed(true);
				if (targetPiece instanceof Armored)
					((Armored) targetPiece).setArmorUp(false);
				l = new Point(Integer.parseInt("" + powerTargets.charAt(2)),
						Integer.parseInt("" + powerTargets.charAt(3)));

				game = clearAndInsert(game,
						new Object[][] { { userLoc.x, userLoc.y, t },
								{ l.x, l.y, targetPiece } });

				t.usePower(null, targetPiece, null);

				break;

			default:
				break;
			}
			break;

		case 'R':

			Ranged r = new Ranged(currentPlayer, game, "Ranged");
			game = clearAndInsert(
					game,
					new Object[][] {
							{ userLoc.x, userLoc.y, r },
							{
									targetLoc.x,
									targetLoc.y,
									createPiece(powerTargets.charAt(0), enemy,
											game) } });

			r.usePower(powerDir, null, null);

			break;

		case 'M':

			Medic m = new Medic(currentPlayer, game, "Medic");
			game = clearAndInsert(game, new Object[][] { { userLoc.x,
					userLoc.y, m } });

			currentPlayer.getDeadCharacters().clear();
			currentPlayer.getDeadCharacters().add(
					createPiece(powerTargets.charAt(0), currentPlayer, game));
			m.usePower(powerDir, currentPlayer.getDeadCharacters().get(0), null);

			break;
		case 'K':
			int playerNo = Integer.parseInt(powerTargets);
			SideKick sk = (playerNo == 1) ? new SideKickP1(game, "Sidekick")
					: new SideKickP2(game, "Sidekick");
			game = clearAndInsert(game, new Object[][] { { userLoc.x,
					userLoc.y, sk } });
			game.setCurrentPlayer((playerNo == 1) ? game.getPlayer1() : game
					.getPlayer2());

			sk.move(powerDir);

			break;

		}

		assertEquals(
				"After using the "
						+ createPiece(powerUser, currentPlayer, game)
								.getClass().getSimpleName()
						+ " power, the turn should "
						+ (shouldSwitch ? "" : "not ") + "be switched",
				shouldSwitch, switchTurnsCalled);

	}

	private void testUsePowerHelper(char powerUser, String powerTargets,
			Point userLoc, Direction powerDir, Point targetLoc,
			boolean powerUsedBefore, boolean onEnemy) throws Exception {

		Game game = createGameForUsePower();
		Player currentPlayer = game.getCurrentPlayer();
		Player enemy = (game.getPlayer1() == currentPlayer ? game.getPlayer2()
				: game.getPlayer1());

		switch (powerUser) {

		case 'R':
			testUsePowerRangedHelper(game, currentPlayer, enemy, powerUser,
					powerTargets, userLoc, powerDir, targetLoc,
					powerUsedBefore, onEnemy);
			break;

		case 'P':

			Point target1LocP = getFinalDestination(userLoc, powerDir, 1, true);
			Point target2LocP = getFinalDestination(userLoc, powerDir, 2, true);

			testMoveSpeedsterHelper(game, currentPlayer, enemy, powerTargets,
					userLoc, powerDir,
					new Point[] { target1LocP, target2LocP }, powerUsedBefore,
					onEnemy);
			break;

		case 'S':

			Point target1LocS = getFinalDestination(userLoc, powerDir, 1, true);
			Point target2LocS = getFinalDestination(userLoc, powerDir, 2, true);

			testUsePowerSuperHelper(game, currentPlayer, enemy, powerTargets,
					userLoc, powerDir,
					new Point[] { target1LocS, target2LocS }, powerUsedBefore,
					onEnemy);
			break;

		case 'T':

			boolean correctTurn = (powerDir == null);

			testUsePowerTechHelper(game, currentPlayer, enemy, powerTargets,
					userLoc, null, targetLoc, powerUsedBefore, onEnemy,
					correctTurn);

			break;

		case 'M':

			testUsePowerMedicHelper(game, currentPlayer, enemy, powerUser,
					powerTargets, userLoc, powerDir, targetLoc,
					powerUsedBefore, onEnemy);
			break;

		}

	}

	private void testUsePowerMedicHelper(Game game, Player currentPlayer,
			Player enemy, char powerUser, String powerTargets, Point userLoc,
			Direction powerDir, Point targetLoc, boolean powerUsedBefore,
			boolean onEnemy) throws Exception {
		Piece targetPiece = createPiece(powerTargets.charAt(0), currentPlayer,
				game);
		Medic m = new Medic(currentPlayer, game, "Medic");

		if (powerUsedBefore) {
			currentPlayer.getDeadCharacters().clear();
			currentPlayer.getDeadCharacters().add(targetPiece);
			testVariablePowerUsedValueSetter(m, true);
			try {
				m.usePower(powerDir, currentPlayer.getDeadCharacters().get(0),
						null);

				fail("Whenever "
						+ m.getClass().getSimpleName()
						+ " hero tries to use its power in a direction that will hit a friendly piece, an InvalidPowerDirectionException should be thrown.");
			} catch (PowerAlreadyUsedException e) {

				assertEquals(
						"Whenever "
								+ m.getClass().getSimpleName()
								+ " hero tries to ressurect a friendly piece while the power has already been used, the frienldy piece should not be removed from the deadCharacters list.",
						1, currentPlayer.getDeadCharacters().size());
				assertEquals(
						"Whenever "
								+ m.getClass().getSimpleName()
								+ " hero tries to ressurect a friendly piece while the power has already been used, the frienldy piece should not be removed from the deadCharacters list.",
						targetPiece, currentPlayer.getDeadCharacters().get(0));
				targetLoc = getFinalDestination(userLoc, powerDir, 1, true);
				assertNotEquals(
						"Whenever "
								+ m.getClass().getSimpleName()
								+ " hero tries to ressurect a friendly piece while the power has already been used, the frienldy piece should not be placed in the target location on the board.",
						targetPiece, game.getCellAt(targetLoc.x, targetLoc.y));
			}
			return;
		}

		if (targetLoc != null) {
			game = clearAndInsert(game, new Object[][] {
					{ userLoc.x, userLoc.y, m },
					{ targetLoc.x, targetLoc.y, targetPiece } });
			currentPlayer.getDeadCharacters().clear();
			currentPlayer.getDeadCharacters().add(targetPiece);

			testVariablePowerUsedValueSetter(m, false);
			try {
				m.usePower(powerDir, currentPlayer.getDeadCharacters().get(0),
						null);
				fail("Whenever "
						+ m.getClass().getSimpleName()
						+ " tries to revive a dead friendly piece in a direction which would result in an occupied cell (by either a friendly or an enemy piece) then an InvalidPowerTargetException should be thrown.");
			} catch (InvalidPowerTargetException e) {

			}
			return;
		}

		if (onEnemy) {
			Player otherPlayer = currentPlayer == game.getPlayer1() ? game
					.getPlayer2() : game.getPlayer1();
			targetPiece = createPiece(powerTargets.charAt(0), otherPlayer, game);
			currentPlayer.getDeadCharacters().clear();
			otherPlayer.getDeadCharacters().clear();
			otherPlayer.getDeadCharacters().add(targetPiece);
			try {
				m.usePower(powerDir, otherPlayer.getDeadCharacters().get(0),
						null);
				fail("Whenever "
						+ m.getClass().getSimpleName()
						+ " tries to revive an enemy piece an InvalidPowerTargetException should be thrown.");
			} catch (InvalidPowerTargetException e) {
			}
			return;
		}

		if (powerTargets.length() > 1 && powerTargets.charAt(1) == 'A') {

			currentPlayer.getDeadCharacters().clear();
			try {
				m.usePower(powerDir, targetPiece, null);
				fail("Whenever "
						+ m.getClass().getSimpleName()
						+ " tries to revive an alive friendly piece an InvalidPowerTargetException should be thrown.");
			} catch (InvalidPowerTargetException e) {

			}
			return;
		}

		game = clearAndInsert(game,
				new Object[][] { { userLoc.x, userLoc.y, m } });
		currentPlayer.getDeadCharacters().clear();
		currentPlayer.getDeadCharacters().add(targetPiece);
		targetLoc = getFinalDestination(userLoc, powerDir, 1, true);

		if (!powerUsedBefore) {
			testVariablePowerUsedValueSetter(m, false);
			try {
				m.usePower(powerDir, currentPlayer.getDeadCharacters().get(0),
						null);

				assertEquals(
						"Whenever a Medic hero ressurects a friendly piece, that piece should be removed from the deadCharacters list.",
						0, currentPlayer.getDeadCharacters().size());
				testVariablePowerUsedValue(m, true);
				assertEquals(
						"Whenever a Medic hero ressurects a friendly piece, that piece should be placed in the target location on the board.",
						targetPiece, game.getCellAt(targetLoc.x, targetLoc.y)
								.getPiece());
				assertEquals(
						"Whenever a Medic hero ressurects a friendly piece, the \"posI\" value of that piece should be updated correctly.",
						targetLoc.x, targetPiece.getPosI());
				assertEquals(
						"Whenever a Medic hero ressurects a friendly piece, the \"posJ\" value of that piece should be updated correctly.",
						targetLoc.y, targetPiece.getPosJ());
				if (targetPiece instanceof Armored)
					testVariableArmoredUpValue((Armored) targetPiece, true);
				else if (targetPiece instanceof ActivatablePowerHero)
					testVariablePowerUsedValue(
							(ActivatablePowerHero) targetPiece, false);

			} catch (InvalidPowerUseException e) {
				fail(m.getClass().getSimpleName()
						+ " hero should be able to use its power if it was not used before and its direction is valid.");
			}

		}
	}

	private void testMoveSpeedsterHelper(Game game, Player currentPlayer,
			Player enemy, String powerTargets, Point userLoc,
			Direction powerDir, Point[] targetLocs, boolean correctTurn,
			boolean jump) throws Exception {

		Speedster s;
		if (correctTurn)
			s = createSpeedsterForAttack(currentPlayer, game, "Speedster");
		else
			s = createSpeedsterForAttack(enemy, game, "Speedster");

		Piece targetPiece1;
		if (powerTargets.charAt(0) == 'E')
			targetPiece1 = createPiece(powerTargets.charAt(1), enemy, game);
		else
			targetPiece1 = createPiece(powerTargets.charAt(1), currentPlayer,
					game);

		Piece targetPiece2;
		if (powerTargets.charAt(2) == 'E')
			targetPiece2 = createPiece(powerTargets.charAt(3), enemy, game);
		else
			targetPiece2 = createPiece(powerTargets.charAt(3), currentPlayer,
					game);

		game = clearAndInsert(game, new Object[][] {
				{ userLoc.x, userLoc.y, s },
				{ targetLocs[0].x, targetLocs[0].y, targetPiece1 },
				{ targetLocs[1].x, targetLocs[1].y, targetPiece2 } });

		if (!correctTurn) {

			try {
				s.move(powerDir);
				fail("While moving, if it's not the correct player's turn a WrongTurnException should be thrown.");
			} catch (WrongTurnException e) {
				return;
			} catch (Exception e) {
				fail("While moving, if it's not the correct player's turn a WrongTurnException should be thrown.");
			}

		}

		Field f = Game.class.getDeclaredField("board");
		f.setAccessible(true);
		Cell[][] board = (Cell[][]) f.get(game);

		Point newPosition = getFinalDestination(userLoc, powerDir, 2, true);
		Piece x = board[newPosition.x][newPosition.y].getPiece();

		if (x != null && x.getOwner() == currentPlayer) {

			try {
				s.move(powerDir);
				fail("If the destination of the move of any piece contains a friendly piece then an OccupiedCellException should be thrown.");
			} catch (OccupiedCellException e) {
				return;
			} catch (Exception e) {
				fail("If the destination of the move of any piece contains a friendly piece then an OccupiedCellException should be thrown.");
			}

		}

		s.move(powerDir);

		if (jump) {

			assertEquals(
					"Speedster heroes move two steps away and have to overstep any adjacent enemy pieces leaving them unharmed in the process.",
					targetPiece1,
					board[targetLocs[0].x][targetLocs[0].y].getPiece());

		}

		assertTrue(
				"Move method should handle piece eliminations resulting from movements by calling the attack method.",
				attackCalled);
		assertEquals(
				"Move method should handle piece eliminations resulting from movements by calling the attack method with the correct piece.",
				x, attackedPiece1);

		assertEquals("The posI attribute of the piece is incorrect.",
				newPosition.x, s.getPosI());
		assertEquals("The posJ attribute of the piece is incorrect.",
				newPosition.y, s.getPosJ());
		assertEquals("The piece found in the destination cell is incorrect.",
				s, board[newPosition.x][newPosition.y].getPiece());
		assertEquals("The piece found in the original cell is incorrect.",
				null, board[userLoc.x][userLoc.y].getPiece());

	}

	private void testUsePowerRangedHelper(Game game, Player currentPlayer,
			Player enemy, char powerUser, String powerTargets, Point userLoc,
			Direction powerDir, Point targetLoc, boolean powerUsedBefore,
			boolean onEnemy) throws Exception {

		Ranged r = createRangedForAttack(currentPlayer, game, "Ranged");
		Piece targetPiece;
		if (onEnemy)
			targetPiece = createPiece(powerTargets.charAt(0), enemy, game);
		else
			targetPiece = createPiece(powerTargets.charAt(0), currentPlayer,
					game);

		game = clearAndInsert(game, new Object[][] {
				{ userLoc.x, userLoc.y, r },
				{ targetLoc.x, targetLoc.y, targetPiece } });

		if (powerUsedBefore) {
			testVariablePowerUsedValueSetter(r, true);
			try {
				r.usePower(powerDir, null, null);
				fail("Whenever "
						+ r.getClass().getSimpleName()
						+ " hero tries to use its power while it has already been used then a PowerAlreadyUsedException needs to be thrown.");
			} catch (PowerAlreadyUsedException e) {

			}
			return;
		}

		if (!onEnemy) {
			try {
				r.usePower(powerDir, null, null);
				fail("If a "
						+ r.getClass().getSimpleName()
						+ " hero tries to use its power in a direction that will hit a friendly piece, an InvalidPowerDirectionException should be thrown.");
			} catch (InvalidPowerUseException e) {
				assertFalse("attack method should not be called whenever "
						+ r.getClass().getSimpleName()
						+ " hero uses its power on a friendly piece.",
						attackCalled);
				assertNotEquals("attack method should not be called whenever "
						+ r.getClass().getSimpleName()
						+ " hero uses its power on a friendly piece.",
						targetPiece, attackedPiece1);
				testVariablePowerUsedValue(r, false);
			}
			return;
		}

		if (!(powerDir == Direction.UP || powerDir == Direction.DOWN
				|| powerDir == Direction.LEFT || powerDir == Direction.RIGHT)) {
			try {
				r.usePower(powerDir, null, null);
				fail("Whenever "
						+ r.getClass().getSimpleName()
						+ " hero tries to use its power in a direction which is not allowed (diagonal) an InvalidPowerDirectionException should be thrown.");
			} catch (InvalidPowerDirectionException e) {

			}
			return;
		}

		if (!powerUsedBefore) {
			testVariablePowerUsedValueSetter(r, false);
			if (powerDir == Direction.UP || powerDir == Direction.DOWN
					|| powerDir == Direction.LEFT
					|| powerDir == Direction.RIGHT) {

				if (!((powerDir == Direction.UP && targetLoc.x < userLoc.x && targetLoc.y == userLoc.y)
						|| (powerDir == Direction.DOWN
								&& targetLoc.x > userLoc.x && targetLoc.y == userLoc.y)
						|| (powerDir == Direction.RIGHT
								&& targetLoc.x == userLoc.x && targetLoc.y > userLoc.y) || (powerDir == Direction.LEFT
						&& targetLoc.x == userLoc.x && targetLoc.y < userLoc.y))) {
					try {
						r.usePower(powerDir, null, null);
						if ((powerDir == Direction.UP && userLoc.x == 0)
								|| (powerDir == Direction.DOWN && userLoc.x == 6)
								|| (powerDir == Direction.LEFT && userLoc.y == 0)
								|| (powerDir == Direction.RIGHT && userLoc.y == 5)) {
							fail("Whenever "
									+ r.getClass().getSimpleName()
									+ " hero tries to use use its power in a direction that needs wrapping an InvalidPowerDirectionException is thrown.");

						} else {
							fail("Whenever "
									+ r.getClass().getSimpleName()
									+ " hero tries to use its power in a direction with no pieces in that direction an InvalidPowerDirectionException is thrown.");
						}
					} catch (InvalidPowerUseException e) {

					}
					return;
				}

				try {
					r.usePower(powerDir, null, null);

					assertTrue("attack method should be called whenever "
							+ r.getClass().getSimpleName()
							+ " hero uses its power on an enemy piece.",
							attackCalled);
					assertEquals(
							"attack method should be called with the correct parameter whenever "
									+ r.getClass().getSimpleName()
									+ " hero uses its power on an enemy piece.",
							targetPiece, attackedPiece1);
					testVariablePowerUsedValue(r, true);

				} catch (Exception e) {
					fail(r.getClass().getSimpleName()
							+ " hero should be able to use its power if it was not used before and its direction is valid.");
				}
			}

		}

	}

	private void testUsePowerSideKickHelper(String powerTargets, int playerNo,
			Point userLoc, Direction powerDir, boolean correctTurn,
			boolean onEnemy, boolean validDirection) throws Exception {
		Game game = createGameForUsePower();
		Player currentPlayer = (playerNo == 1) ? game.getPlayer1() : game
				.getPlayer2();
		game.setCurrentPlayer(currentPlayer);
		attackedPiece1 = null;
		attackCalled = false;
		SideKick s = (playerNo == 1) ? new SideKickP1(game, "Sidekick") {

			@Override
			public void attack(Piece p2) {
				attackCalled = true;
				attackedPiece1 = p2;
				super.attack(p2);
			}

		} : new SideKickP2(game, "Sidekick") {

			@Override
			public void attack(Piece p2) {
				attackCalled = true;
				attackedPiece1 = p2;
				super.attack(p2);
			}

		};
		Point targetLoc = getFinalDestination(userLoc, powerDir, 1, true);
		Piece targetPiece;
		Player targetPlayer;

		if (onEnemy)
			targetPlayer = (game.getPlayer1() == currentPlayer ? game
					.getPlayer2() : game.getPlayer1());
		else
			targetPlayer = (game.getPlayer1() == currentPlayer ? game
					.getPlayer1() : game.getPlayer2());

		targetPiece = createPiece(powerTargets.charAt(0), targetPlayer, game);
		if (targetPiece instanceof Armored && powerTargets.charAt(1) == 'F')
			testVariableArmoredUpValueSetter((Armored) targetPiece, false);
		else {
			if (targetPiece instanceof Armored && powerTargets.charAt(1) == 'T')
				testVariableArmoredUpValueSetter((Armored) targetPiece, true);
		}

		game = clearAndInsert(game, new Object[][] {
				{ userLoc.x, userLoc.y, s },
				{ targetLoc.x, targetLoc.y, targetPiece } });

		if (!correctTurn) {
			try {
				game.setCurrentPlayer(targetPlayer);
				s.move(powerDir);
				fail("Whenever "
						+ s.getClass().getSimpleName()
						+ " tries to move in the wrong turn a WrongTurnException should be thrown.");
			} catch (WrongTurnException e) {

			}
			return;
		} else if (!validDirection) {
			try {
				s.move(powerDir);
				fail("Whenever "
						+ s.getClass().getSimpleName()
						+ " tries to move in a direction which is not allowed an UnallowedMovementException should be thrown.");
			} catch (UnallowedMovementException e) {

			}
			return;
		} else {
			if (!onEnemy) {
				try {
					s.move(powerDir);
					fail("Whenever "
							+ s.getClass().getSimpleName()
							+ " tries to move to a cell occupied by a friendly piece an OccupiedCellException should be thrown.");
				} catch (OccupiedCellException e) {
					return;
				}

			}
			s.move(powerDir);
			Piece newPiece = game.getCellAt(targetLoc.x, targetLoc.y)
					.getPiece();
			assertTrue("attack method should be called whenever "
					+ s.getClass().getSimpleName()
					+ " moves to a cell containing an enemy piece.",
					attackCalled);
			assertEquals(
					"attack method should be called with the correct parameter whenever "
							+ s.getClass().getSimpleName()
							+ " moves to a cell containing an enemy piece.",
					targetPiece, attackedPiece1);

			if (targetPiece instanceof Armored && powerTargets.charAt(1) == 'T') {
				testVariableArmoredUpValue((Armored) targetPiece, false);
				return;
			}

			assertNotEquals(
					"Whenever "
							+ s.getClass().getSimpleName()
							+ " eliminates a hero piece, this sidekick piece is replaced with a new hero piece of the same type of the eliminated hero piece.",
					targetPiece, newPiece);

			String c = "";

			if (!(newPiece instanceof SideKick)) {
				assertEquals(
						"Whenever a sidekick piece eliminates a hero piece, this sidekick piece should be replaced with a new hero piece of the same player of the eliminated hero piece.",
						currentPlayer, game.getCellAt(targetLoc.x, targetLoc.y)
								.getPiece().getOwner());

				switch (powerTargets.charAt(0)) {
				case 'P':
					c = Speedster.class.getSimpleName();
					break;
				case 'S':
					c = Super.class.getSimpleName();
					break;
				case 'T':
					c = Tech.class.getSimpleName();
					break;
				case 'R':
					c = Ranged.class.getSimpleName();
					break;
				case 'A':
					c = Armored.class.getSimpleName();
					break;

				case 'M':
					c = Medic.class.getSimpleName();
					break;

				}
				assertEquals(
						"Whenever a sidekick piece eliminates a hero piece, this sidekick piece should be replaced with a new hero piece of the same type of the eliminated hero piece.",
						c, newPiece.getClass().getSimpleName());

				if (targetPiece instanceof ActivatablePowerHero)
					testVariablePowerUsedValue((ActivatablePowerHero) newPiece,
							false);
				else if (targetPiece instanceof Armored)
					testVariableArmoredUpValue((Armored) newPiece, true);
			}
		}

	}

	private void testUsePowerSuperHelper(Game game, Player currentPlayer,
			Player enemy, String powerTargets, Point userLoc,
			Direction powerDir, Point[] targetLocs, boolean powerUsedBefore,
			boolean correctTurn) throws Exception {

		Super s;
		String superClassName = "Super";
		if (correctTurn)
			s = createSuperForAttack(currentPlayer, game, "Super");
		else
			s = createSuperForAttack(enemy, game, "Super");

		Piece targetPiece1;
		if (powerTargets.charAt(0) == 'E')
			targetPiece1 = createPiece(powerTargets.charAt(1), enemy, game);
		else
			targetPiece1 = createPiece(powerTargets.charAt(1), currentPlayer,
					game);

		Piece targetPiece2;
		if (powerTargets.charAt(2) == 'E')
			targetPiece2 = createPiece(powerTargets.charAt(3), enemy, game);
		else
			targetPiece2 = createPiece(powerTargets.charAt(3), currentPlayer,
					game);

		game = clearAndInsert(game, new Object[][] {
				{ userLoc.x, userLoc.y, s },
				{ targetLocs[0].x, targetLocs[0].y, targetPiece1 },
				{ targetLocs[1].x, targetLocs[1].y, targetPiece2 } });

		if (powerUsedBefore) {

			testVariablePowerUsedValueSetter(s, true);
			try {
				s.usePower(powerDir, null, null);
				fail("Whenever "
						+ superClassName
						+ " hero tries to use its power while it has already been used then a PowerAlreadyUsedException needs to be thrown.");
			} catch (PowerAlreadyUsedException e) {
				return;
			}

		}

		testVariablePowerUsedValueSetter(s, false);

		if (!correctTurn) {

			try {
				s.usePower(powerDir, null, null);
				fail("Whenever "
						+ superClassName
						+ " hero tries to use its power in the wrong turn a WrongTurnException should be thrown.");
			} catch (WrongTurnException e) {
				return;
			}

		}

		if (!(powerDir == Direction.UP || powerDir == Direction.DOWN
				|| powerDir == Direction.LEFT || powerDir == Direction.RIGHT)) {

			Exception ex = null;
			try {
				s.usePower(powerDir, null, null);
			} catch (InvalidPowerDirectionException e) {
				ex = e;
			}
			assertThat(
					"Whenever a Super tries to use the power in a direction that is not allowed by the game rules (diagonal) an InvalidPowerDirectionException should be thrown.",
					ex, CoreMatchers
							.instanceOf(InvalidPowerDirectionException.class));
			return;
		}

		try {

			s.usePower(powerDir, null, null);

			ArrayList<Piece> x = new ArrayList<Piece>();
			if (attackedPiece1 != null)
				x.add(attackedPiece1);
			if (attackedPiece2 != null)
				x.add(attackedPiece2);
			if (x.isEmpty())
				x.add(null);

			if (targetPiece1 != null)
				if (powerTargets.charAt(0) == 'E')
					if (!isWrappedTarget(userLoc, targetLocs[0], powerDir)) {

						assertTrue("attack method should be called whenever "
								+ superClassName
								+ " uses its power on an enemy piece.",
								attackCalled);

						assertThat(
								"attack method should be called with the correct parameter whenever "
										+ superClassName
										+ " uses its power on an enemy piece.",
								x, CoreMatchers.hasItem(targetPiece1));

					} else
						assertThat(
								"The power of the Super hero can not be wrapped.",
								x, CoreMatchers.not(CoreMatchers
										.hasItem(targetPiece1)));
				else
					assertThat(
							"The power of the Super hero can not be applied on a friendly piece.",
							x, CoreMatchers.not(CoreMatchers
									.hasItem(targetPiece1)));

			if (targetPiece2 != null)
				if (powerTargets.charAt(2) == 'E')
					if (!isWrappedTarget(userLoc, targetLocs[1], powerDir)) {

						assertTrue("attack method should be called whenever "
								+ superClassName
								+ " uses its power on an enemy piece.",
								attackCalled);

						assertThat(
								"attack method should be called with the correct parameter whenever "
										+ superClassName
										+ " uses its power on an enemy piece.",
								x, CoreMatchers.hasItem(targetPiece2));

					} else
						assertThat(
								"The power of the Super hero can not be wrapped.",
								x, CoreMatchers.not(CoreMatchers
										.hasItem(targetPiece2)));
				else
					assertThat(
							"The power of the Super hero can not be applied on a friendly piece.",
							x, CoreMatchers.not(CoreMatchers
									.hasItem(targetPiece2)));

			testVariablePowerUsedValue(s, true);

		} catch (InvalidPowerUseException e) {
			fail("Whenever "
					+ superClassName
					+ " hero tries to use its power in a direction that is not allowed by the game rules (diagonal) an InvalidPowerDirectionException is thrown");
		}

	}

	private void testUsePowerTechHelper(Game game, Player currentPlayer,
			Player enemy, String powerTargets, Point userLoc,
			Direction powerDir, Point targetLoc, boolean powerUsedBefore,
			boolean invalid, boolean correctTurn) throws Exception {

		Tech t;
		if (correctTurn)
			t = (Tech) createPiece('T', currentPlayer, game);
		else
			t = (Tech) createPiece('T', enemy, game);

		Piece targetPiece;
		if (powerTargets.charAt(1) == 'E')
			targetPiece = createPiece(powerTargets.charAt(2), enemy, game);
		else
			targetPiece = createPiece(powerTargets.charAt(2), currentPlayer,
					game);

		Point l = new Point(Integer.parseInt("" + powerTargets.charAt(3)),
				Integer.parseInt("" + powerTargets.charAt(4)));

		game = clearAndInsert(game, new Object[][] {
				{ userLoc.x, userLoc.y, t }, { l.x, l.y, targetPiece } });

		if (powerUsedBefore) {

			testVariablePowerUsedValueSetter(t, true);
			try {
				t.usePower(null, targetPiece, targetLoc);
				fail("When using power, if the power has already been used then a PowerAlreadyUsedException needs to be thrown.");
			} catch (PowerAlreadyUsedException e) {
				return;
			} catch (Exception e) {
				fail("When using power, if the power has already been used then a PowerAlreadyUsedException needs to be thrown.");
			}

		}

		testVariablePowerUsedValueSetter(t, false);

		if (!correctTurn) {

			try {
				t.usePower(null, targetPiece, targetLoc);
				fail("When using power, if it's not the correct player's turn a WrongTurnException should be thrown.");
			} catch (WrongTurnException e) {
				return;
			} catch (Exception e) {
				fail("When using power, if it's not the correct player's turn a WrongTurnException should be thrown.");
			}

		}

		Field f = Game.class.getDeclaredField("board");
		f.setAccessible(true);
		Cell[][] board = (Cell[][]) f.get(game);

		switch (powerTargets.charAt(0)) {
		case 'T': // Teleport

			if (invalid) {

				if (targetPiece.getOwner() == currentPlayer) {
					board[targetLoc.x][targetLoc.y].setPiece(createPiece('S',
							enemy, game));
					try {
						t.usePower(null, targetPiece, targetLoc);
						fail("If the destination of the teleport power is occupied by either a friendly or an enemy piece, an InvalidPowerTargetException should be thrown.");
					} catch (InvalidPowerTargetException e) {
						return;
					} catch (Exception e) {
						fail("If the destination of the teleport power is occupied by either a friendly or an enemy piece, an InvalidPowerTargetException should be thrown.");
					}
				} else {
					try {
						t.usePower(null, targetPiece, targetLoc);
						fail("If a Tech tries to use teleport on an enemy piece, an InvalidPowerTargetException should be thrown.");
					} catch (InvalidPowerTargetException e) {
						return;
					} catch (Exception e) {
						fail("If a Tech tries to use teleport on an enemy piece, an InvalidPowerTargetException should be thrown.");
					}
				}

			} else {

				t.usePower(null, targetPiece, targetLoc);

				testVariablePowerUsedValue(t, true);

				assertEquals("The posI attribute of the piece is incorrect.",
						targetLoc.x, targetPiece.getPosI());
				assertEquals("The posJ attribute of the piece is incorrect.",
						targetLoc.y, targetPiece.getPosJ());
				assertEquals(
						"The piece found in the destination cell is incorrect.",
						targetPiece, board[targetLoc.x][targetLoc.y].getPiece());
				assertEquals(
						"The piece found in the original cell is incorrect.",
						null, board[l.x][l.y].getPiece());

			}

			break;

		case 'H': // Hack

			if (invalid) {

				if (targetPiece instanceof ActivatablePowerHero) {

					((ActivatablePowerHero) targetPiece).setPowerUsed(true);

					try {
						t.usePower(null, targetPiece, null);
						fail("If a Tech tries to hack an enemy target that already used its power, an InvalidPowerTargetException should be thrown.");
					} catch (InvalidPowerTargetException e) {
						return;
					} catch (Exception e) {
						fail("If a Tech tries to hack an enemy target that already used its power, an InvalidPowerTargetException should be thrown.");
					}
				}
				if (targetPiece instanceof Armored) {

					((Armored) targetPiece).setArmorUp(false);

					try {
						t.usePower(null, targetPiece, null);
						fail("If a Tech tries to hack an enemy Armored that already dropped its shield, an InvalidPowerTargetException should be thrown.");
					} catch (InvalidPowerTargetException e) {
						return;
					} catch (Exception e) {
						fail("If a Tech tries to hack an enemy Armored that already dropped its shield, an InvalidPowerTargetException should be thrown.");
					}

				}

			} else {
				if (targetPiece instanceof ActivatablePowerHero) {

					((ActivatablePowerHero) targetPiece).setPowerUsed(false);

					t.usePower(null, targetPiece, null);

					testVariablePowerUsedValue(t, true);
					testVariablePowerUsedValue(
							((ActivatablePowerHero) targetPiece), true);

				}
				if (targetPiece instanceof Armored) {

					((Armored) targetPiece).setArmorUp(true);

					t.usePower(null, targetPiece, null);

					testVariablePowerUsedValue(t, true);
					Field fA = Armored.class.getDeclaredField("armorUp");
					fA.setAccessible(true);
					assertFalse(
							"If a Tech tries to hack an enemy Armored with their armor up, the armor should be dropped as a result of the hack.",
							(boolean) fA.get(((Armored) targetPiece)));
				}

			}
			break;

		case 'U': // Restore

			if (invalid) {

				if (targetPiece instanceof ActivatablePowerHero) {

					((ActivatablePowerHero) targetPiece).setPowerUsed(false);

					try {
						t.usePower(null, targetPiece, null);
						fail("If a Tech tries to restore the ability of a friendly piece that did not use its power yet, an InvalidPowerTargetException should be thrown.");
					} catch (InvalidPowerTargetException e) {
						return;
					} catch (Exception e) {
						fail("If a Tech tries to restore the ability of a friendly piece that did not use its power yet, an InvalidPowerTargetException should be thrown.");
					}
				}
				if (targetPiece instanceof Armored) {

					((Armored) targetPiece).setArmorUp(true);

					try {
						t.usePower(null, targetPiece, null);
						fail("If a Tech tries to restore the shield of a friendly Armored that did not drop its shield yet, an InvalidPowerTargetException should be thrown.");
					} catch (InvalidPowerTargetException e) {
						return;
					} catch (Exception e) {
						fail("If a Tech tries to restore the shield of a friendly Armored that did not drop its shield yet, an InvalidPowerTargetException should be thrown.");
					}

				}

			} else {
				if (targetPiece instanceof ActivatablePowerHero) {

					((ActivatablePowerHero) targetPiece).setPowerUsed(true);

					t.usePower(null, targetPiece, null);

					testVariablePowerUsedValue(t, true);
					testVariablePowerUsedValue(
							((ActivatablePowerHero) targetPiece), false);

				}
				if (targetPiece instanceof Armored) {

					((Armored) targetPiece).setArmorUp(false);

					t.usePower(null, targetPiece, null);

					testVariablePowerUsedValue(t, true);
					Field fA = Armored.class.getDeclaredField("armorUp");
					fA.setAccessible(true);
					assertTrue(
							"If a Tech tries to restore the shield of a friendly Armored with their armor down, the armor should be up as a result of the power",
							(boolean) fA.get(((Armored) targetPiece)));
				}

			}

			break;

		default:
			break;
		}

	}

	private void testUsePowerWrongTurnHelper(char powerUser,
			String powerTargets, Point userLoc, Direction powerDir,
			Point targetLoc) throws Exception {

		Game game = createGameForUsePower();
		Player currentPlayer = game.getCurrentPlayer();
		Player enemy = (game.getPlayer1() == currentPlayer ? game.getPlayer2()
				: game.getPlayer1());

		ActivatablePowerHero r = (powerUser == 'R') ? new Ranged(currentPlayer,
				game, "Ranged") : new Medic(currentPlayer, game, "Medic");
		Piece targetPiece = createPiece(powerTargets.charAt(0), enemy, game);
		if (targetLoc != null) {
			game = clearAndInsert(game, new Object[][] {
					{ userLoc.x, userLoc.y, r },
					{ targetLoc.x, targetLoc.y, targetPiece } });
		} else {
			game = clearAndInsert(game, new Object[][] { { userLoc.x,
					userLoc.y, r } });
		}

		testVariablePowerUsedValueSetter(r, false);
		game.setCurrentPlayer(enemy);
		try {
			r.usePower(powerDir, null, null);
			fail("Whenever "
					+ r.getClass().getSimpleName()
					+ " hero tries to use its power in the wrong turn a WrongTurnException should be thrown.");
		} catch (WrongTurnException e) {

		}
	}

	private void testVariableArmoredUpValue(Armored r, boolean shouldBeUp)
			throws NoSuchFieldException, SecurityException,
			IllegalArgumentException, IllegalAccessException {
		Field f = Armored.class.getDeclaredField("armorUp");
		f.setAccessible(true);
		assertEquals(
				r.getClass().getSimpleName()
						+ " hero should update the value of the \"armorUp\" variable correctly.",
				shouldBeUp, (boolean) f.get(r));
	}

	private void testVariableArmoredUpValueSetter(Armored r, boolean value)
			throws NoSuchFieldException, SecurityException,
			IllegalArgumentException, IllegalAccessException {
		Field f = Armored.class.getDeclaredField("armorUp");
		f.setAccessible(true);
		f.set(r, value);
	}

	private void testVariablePowerUsedValue(ActivatablePowerHero r,
			boolean shouldBeUsed) throws NoSuchFieldException,
			SecurityException, IllegalArgumentException, IllegalAccessException {
		Field f = ActivatablePowerHero.class.getDeclaredField("powerUsed");
		f.setAccessible(true);
		assertEquals(
				r.getClass().getSimpleName()
						+ " hero should update the value of the \"powerUsed\" variable correctly",
				shouldBeUsed, (boolean) f.get(r));
	}

	private void testVariablePowerUsedValueSetter(ActivatablePowerHero r,
			boolean value) throws NoSuchFieldException, SecurityException,
			IllegalArgumentException, IllegalAccessException {
		Field f = ActivatablePowerHero.class.getDeclaredField("powerUsed");
		f.setAccessible(true);
		f.set(r, value);
	}

	private void testExistsInClass(Class aClass, String methodName,
			boolean implementedMethod, Class returnType, Class... inputTypes) {

		Method[] methods = aClass.getDeclaredMethods();

		if (implementedMethod) {
			assertTrue(
					"The " + methodName + " method in class "
							+ aClass.getSimpleName()
							+ " should be implemented.",
					containsMethodName(methods, methodName));
		} else {
			assertFalse(
					"The "
							+ methodName
							+ " method in class "
							+ aClass.getSimpleName()
							+ " should not be implemented, only inherited from super class.",
					containsMethodName(methods, methodName));
			return;
		}
		Method m = null;
		boolean found = true;
		try {
			m = aClass.getDeclaredMethod(methodName, inputTypes);
		} catch (Exception e) {
			found = false;
		}

		String inputsList = "";
		for (Class inputType : inputTypes) {
			inputsList += inputType.getSimpleName() + ", ";
		}
		if (inputsList.equals(""))
			assertTrue(aClass.getSimpleName() + " class should have "
					+ methodName + " method that takes no parameters.", found);
		else {
			if (inputsList.charAt(inputsList.length() - 1) == ' ')
				inputsList = inputsList.substring(0, inputsList.length() - 2);
			assertTrue(aClass.getSimpleName() + " class should have "
					+ methodName + " method that takes " + inputsList
					+ " parameter(s).", found);
		}

		assertTrue("incorrect return type for " + methodName + " method in "
				+ aClass.getSimpleName() + ".",
				m.getReturnType().equals(returnType));

	}

	private Game createGameForSwitchTurn() {

		int random = (int) (Math.random() * 40) + 10;
		random = (int) (Math.random() * 40) + 10;
		Player p1 = new Player("Player_" + random);
		random = (int) (Math.random() * 40) + 10;
		Player p2 = new Player("Player_" + random);
		switchTurnsCalled = false;
		Game g = new Game(p1, p2) {
			@Override
			public void switchTurns() {
				switchTurnsCalled = true;
			}
		};

		return g;

	}

	private Game createGameForUsePower() {

		int random = (int) (Math.random() * 40) + 10;
		random = (int) (Math.random() * 40) + 10;
		Player p1 = new Player("Player_" + random);
		random = (int) (Math.random() * 40) + 10;
		Player p2 = new Player("Player_" + random);

		Game g = new Game(p1, p2);

		return g;

	}

	private Ranged createRangedForAttack(Player p, Game g, String s) {

		Ranged r = null;
		attackedPiece1 = null;
		attackCalled = false;
		r = new Ranged(p, g, s) {
			@Override
			public void attack(Piece p2) {
				attackCalled = true;
				attackedPiece1 = p2;
			}

		};
		return (r);

	}

	private Speedster createSpeedsterForAttack(Player p, Game g, String s) {

		Speedster r = null;
		attackedPiece1 = null;
		attackedPiece2 = null;
		attackCalled = false;
		r = new Speedster(p, g, s) {
			@Override
			public void attack(Piece p2) {
				attackCalled = true;
				if (attackedPiece1 == null)
					attackedPiece1 = p2;
				else
					attackedPiece2 = p2;

				super.attack(p2);

			}

		};
		return (r);

	}

	private Super createSuperForAttack(Player p, Game g, String n) {

		Super s = null;
		attackedPiece1 = null;
		attackedPiece2 = null;
		attackCalled = false;
		s = new Super(p, g, n) {
			@Override
			public void attack(Piece p2) {
				attackCalled = true;
				if (attackedPiece1 == null)
					attackedPiece1 = p2;
				else
					attackedPiece2 = p2;
			}

		};
		return (s);

	}

	private boolean isWrappedTarget(Point pos, Point dest, Direction d) {

		Point p = new Point();
		p.x = pos.x;
		p.y = pos.y;
		boolean wrapped = false;
		switch (d) {
		case DOWN:
			wrapped = dest.x < pos.x;
			break;
		case DOWNLEFT:
			wrapped = dest.x < pos.x;
			wrapped &= dest.y > pos.y;
			break;
		case DOWNRIGHT:
			wrapped = dest.x < pos.x;
			wrapped &= dest.y < pos.y;
			break;
		case LEFT:
			wrapped = dest.y > pos.y;
			break;
		case RIGHT:
			wrapped = dest.y < pos.y;
			break;
		case UP:
			wrapped = dest.x > pos.x;
			break;
		case UPLEFT:
			wrapped = dest.x > pos.x;
			wrapped &= dest.y > pos.y;
			break;
		case UPRIGHT:
			wrapped = dest.x > pos.x;
			wrapped &= dest.y < pos.y;
			break;

		}

		return wrapped;

	}

	private void testAssemblePiecesHelper(int player, String test,
			boolean countOnly) throws Exception {

		assemblePiecesCalled = false;
		Player p1 = new Player("P1");
		Player p2 = new Player("P2");
		Game g = new Game(p1, p2) {

			public void assemblePieces() {
				assemblePiecesCalled = true;
				super.assemblePieces();
			}

		};
		assertTrue(
				"When creating a new game, the pieces should be assembled using the assemblePieces method.",
				assemblePiecesCalled);

		Field f = Game.class.getDeclaredField("board");
		f.setAccessible(true);

		Cell[][] cells = (Cell[][]) f.get(g);
		Piece[][] board = new Piece[7][6];
		for (int i = 0; i < cells.length; i++)
			for (int j = 0; j < cells[i].length; j++)
				if (cells[i][j] != null)
					board[i][j] = cells[i][j].getPiece();
				else
					fail("assemblePieces should populate the board correctly without having any non-instantiated cells.");

		if (test.equalsIgnoreCase("game")) {

			for (int i = 0; i < board.length; i++) {

				for (int j = 0; j < board[i].length; j++) {

					if (board[i][j] == null)
						continue;

					if ((player == 1 && board[i][j].getOwner() == g
							.getPlayer1())
							|| (player == 2 && board[i][j].getOwner() == g
									.getPlayer2()))
						assertEquals(
								"When assembling the pieces, the Game to which each piece belongs should be set correctly.",
								board[i][j].getGame(), g);

				}
			}

			return;
		}

		if (test.equalsIgnoreCase("pos")) {

			for (int i = 0; i < board.length; i++) {

				for (int j = 0; j < board[i].length; j++) {

					if (board[i][j] == null)
						continue;

					if ((player == 1 && board[i][j].getOwner() == g
							.getPlayer1())
							|| (player == 2 && board[i][j].getOwner() == g
									.getPlayer2())) {
						assertEquals(
								"When assembling the pieces, the \"i\" position of the Piece in the 2D Cell array representing the board should be set correctly.",
								board[i][j].getPosI(), i);
						assertEquals(
								"When assembling the pieces, the \"j\" position of the Piece in the 2D Cell array representing the board should be set correctly.",
								board[i][j].getPosJ(), j);
					}

				}
			}

			return;
		}

		ArrayList<Piece> p1Heroes = new ArrayList<Piece>();
		ArrayList<Piece> p1Kicks = new ArrayList<Piece>();
		ArrayList<Piece> p2Heroes = new ArrayList<Piece>();
		ArrayList<Piece> p2Kicks = new ArrayList<Piece>();

		ArrayList<String> heroTypes = new ArrayList<String>();
		heroTypes.add(Medic.class.getSimpleName());
		heroTypes.add(Super.class.getSimpleName());
		heroTypes.add(Tech.class.getSimpleName());
		heroTypes.add(Speedster.class.getSimpleName());
		heroTypes.add(Ranged.class.getSimpleName());
		heroTypes.add(Armored.class.getSimpleName());

		Piece x;

		for (int i = 0; i < board.length; i++) {

			for (int j = 0; j < board[i].length; j++) {

				x = board[i][j];
				if (x == null)
					continue;

				if (x.getOwner() == g.getPlayer1())
					if (x instanceof Hero)
						p1Heroes.add(x);
					else
						p1Kicks.add(x);
				else if (x instanceof Hero)
					p2Heroes.add(x);
				else
					p2Kicks.add(x);

			}

		}

		if (test.equalsIgnoreCase("sideKicks")) {

			if (countOnly) {
				if (player == 1)
					assertEquals(
							"When assembling the pieces, player 1 should have 6 SideKick pieces on the board.",
							6, p1Kicks.size());
				if (player == 2)
					assertEquals(
							"When assembling the pieces, player 2 should have 6 sideKick pieces on the board.",
							6, p2Kicks.size());
			} else {

				ArrayList<String> c = new ArrayList<String>();

				if (player == 2) {
					for (int i = 0; i < board[2].length; i++)
						if (board[2][i] != null)
							c.add(board[2][i].getClass().getSimpleName());

					Collections.sort(c);
					Collections.sort(heroTypes);
					assertThat(
							"When assembling pieces, player 2 should have all their sidekick in their designated sidekick area.",
							c, CoreMatchers.equalTo(heroTypes));

				}
				if (player == 1) {
					for (int i = 0; i < board[4].length; i++)
						if (board[4][i] != null)
							c.add(board[4][i].getClass().getSimpleName());

					Collections.sort(c);
					Collections.sort(heroTypes);
					assertThat(
							"When assembling pieces, player 1 should have all their sidekick in their designated sidekick area.",
							c, CoreMatchers.equalTo(heroTypes));

				}

			}

		}

		if (test.equalsIgnoreCase("heroes")) {

			if (countOnly) {

				if (player == 1)
					assertEquals(
							"When assembling the pieces, player 1 should have 6 Hero pieces on the board.",
							6, p1Heroes.size());
				if (player == 2)
					assertEquals(
							"When assembling the pieces, player 2 should have 6 Hero pieces on the board.",
							6, p2Heroes.size());
			} else {

				ArrayList<String> c = new ArrayList<String>();

				if (player == 2) {
					for (int i = 0; i < board[1].length; i++)
						if (board[1][i] != null)
							c.add(board[1][i].getClass().getSimpleName());

					Collections.sort(c);
					Collections.sort(heroTypes);
					assertThat(
							"When assembling pieces, player 2 should have all their heroes in their designated hero area.",
							c, CoreMatchers.equalTo(heroTypes));

				}
				if (player == 1) {
					for (int i = 0; i < board[5].length; i++)
						if (board[5][i] != null)
							c.add(board[5][i].getClass().getSimpleName());

					Collections.sort(c);
					Collections.sort(heroTypes);
					assertThat(
							"When assembling pieces, player 1 should have all their heroes in their designated hero area.",
							c, CoreMatchers.equalTo(heroTypes));

				}

			}
		}

		if (test.equalsIgnoreCase("type")) {

			ArrayList<Piece> h;
			if (player == 1)
				h = p1Heroes;
			else
				h = p2Heroes;
			ArrayList<String> c = new ArrayList<String>();

			for (Piece p : h)
				c.add(p.getClass().getSimpleName());

			Collections.sort(c);
			Collections.sort(heroTypes);
			assertThat(
					"When assembling pieces, each player should have one hero of each type.",
					c, CoreMatchers.equalTo(heroTypes));

		}

		if (test.equalsIgnoreCase("random")) {

			boolean different = true;

			for (int tr = 0; tr < 5; tr++) {

				Player xp1 = new Player("P1");
				Player xp2 = new Player("P2");
				Game xg = new Game(xp1, xp2);

				Player xPlayer;
				if (player == 1)
					xPlayer = xg.getPlayer1();
				else
					xPlayer = xg.getPlayer2();

				Field xf = Game.class.getDeclaredField("board");
				xf.setAccessible(true);

				Cell[][] xcells = (Cell[][]) xf.get(xg);
				for (int i = 0; i < xcells.length; i++)
					for (int j = 0; j < xcells[i].length; j++)
						if (xcells[i][j] != null) {
							x = xcells[i][j].getPiece();
							if (x != null && x instanceof Hero
									&& x.getOwner() == xPlayer)
								different &= board[i][j].getClass() == x
										.getClass();

						} else
							fail("assemblePieces should populate the board correctly wihout having any non-instantiated cells.");

			}
			assertFalse(
					"When assembling pieces, the heroes of each player should be randomly placed in the player's designated hero area.",
					different);

		}

	}

	private boolean containsMethodName(Method[] methods, String name) {
		for (Method method : methods) {
			if (method.getName().equals(name))
				return true;
		}
		return false;
	}

	private void testMovementToEmptyCell(String hero, int playerNumber,
			Point initPosition, Direction direction, int step, boolean wrapping)
			throws Exception {
		testMovementToEmptyCellHelper((Game) createGame(), hero, playerNumber,
				initPosition, direction, step, wrapping);
	}

	private void testMovementToEmptyCellHelper(Game game, String hero,
			int playerNumber, Point initPosition, Direction direction,
			int step, boolean wrapping) throws Exception {
		Field f = Game.class.getDeclaredField("board");
		f.setAccessible(true);
		if (playerNumber == 1)
			game.setCurrentPlayer(game.getPlayer1());
		else
			game.setCurrentPlayer(game.getPlayer2());
		Player currentPlayer = game.getCurrentPlayer();
		Piece piece = createPiece(convertPathtoChar(hero), currentPlayer, game);
		Point newPosition = getFinalDestination(initPosition, direction, step,
				wrapping);
		game = clearAndInsert(game, new Object[][] { { initPosition.x,
				initPosition.y, piece } });
		Cell[][] board = (Cell[][]) f.get(game);

		game.setCurrentPlayer(piece.getOwner());
		piece.move(direction);

		assertEquals("The posI attribute of the piece is incorrect.",
				newPosition.x, piece.getPosI());
		assertEquals("The posJ attribute of the piece is incorrect.",
				newPosition.y, piece.getPosJ());
		assertEquals("The piece found in the destination cell is incorrect.",
				piece, board[newPosition.x][newPosition.y].getPiece());
		assertEquals("The piece found in the original cell is incorrect.",
				null, board[initPosition.x][initPosition.y].getPiece());
	}

	private void testMovementToFriendCell(String hero, int playerNumber,
			Point initPosition, Direction direction, int step, boolean wrapping)
			throws Exception {
		testMovementToFriendCellHelper((Game) createGame(), hero, playerNumber,
				initPosition, direction, step, wrapping);
	}

	private void testMovementToFriendCellHelper(Game game, String hero,
			int playerNumber, Point initPosition, Direction direction,
			int step, boolean wrapping) throws Exception {
		Field f = Game.class.getDeclaredField("board");
		f.setAccessible(true);
		if (playerNumber == 1)
			game.setCurrentPlayer(game.getPlayer1());
		else
			game.setCurrentPlayer(game.getPlayer2());
		Player currentPlayer = game.getCurrentPlayer();
		Piece heroPiece = createPiece(convertPathtoChar(hero), currentPlayer,
				game);
		Piece friendPiece = createPiece(chooseRandomHero(), currentPlayer, game);

		Point newPosition = getFinalDestination(initPosition, direction, step,
				wrapping);
		game = clearAndInsert(game, new Object[][] {
				{ initPosition.x, initPosition.y, heroPiece },
				{ newPosition.x, newPosition.y, friendPiece } });
		Cell[][] board = (Cell[][]) f.get(game);

		game.setCurrentPlayer(heroPiece.getOwner());
		try {
			heroPiece.move(direction);
			fail("Moving to a cell occupied with a friendly piece should result in an OccupiedCellException.");
		} catch (OccupiedCellException e) {

		}
		assertEquals("The posI attribute of the attacking piece is incorrect.",
				initPosition.x, heroPiece.getPosI());
		assertEquals("The posJ attribute of the attacking piece is incorrect.",
				initPosition.y, heroPiece.getPosJ());
		assertEquals("The piece found in the original cell is incorrect.",
				heroPiece, board[initPosition.x][initPosition.y].getPiece());
		assertEquals("The posI attribute of the attacked piece is incorrect.",
				newPosition.x, friendPiece.getPosI());
		assertEquals("The posJ attribute of the attacked piece is incorrect.",
				newPosition.y, friendPiece.getPosJ());
		assertEquals("The piece found in the destination cell is incorrect.",
				friendPiece, board[newPosition.x][newPosition.y].getPiece());
		assertEquals(
				"The game should not switch turn since the movement is invalid.",
				currentPlayer, game.getCurrentPlayer());
	}

	private void testMovementToEmptyCellSwitchTurn(String hero,
			int playerNumber, Point initPosition, Direction direction,
			int step, boolean wrapping) throws Exception {
		testMovementToEmptyCellSwitchTurnHelper((Game) createGame(), hero,
				playerNumber, initPosition, direction, step, wrapping);
	}

	private void testMovementToEmptyCellSwitchTurnHelper(Game game,
			String hero, int playerNumber, Point initPosition,
			Direction direction, int step, boolean wrapping) throws Exception {
		Field f = Game.class.getDeclaredField("board");
		f.setAccessible(true);
		if (playerNumber == 1)
			game.setCurrentPlayer(game.getPlayer1());
		else
			game.setCurrentPlayer(game.getPlayer2());
		Player currentPlayer = game.getCurrentPlayer();
		Player otherPlayer = game.getPlayer2();
		if (currentPlayer == otherPlayer)
			otherPlayer = game.getPlayer1();

		Piece piece = createPiece(convertPathtoChar(hero), currentPlayer, game);
		game = clearAndInsert(game, new Object[][] { { initPosition.x,
				initPosition.y, piece } });

		game.setCurrentPlayer(piece.getOwner());
		piece.move(direction);

		assertEquals(
				"You should switch the turn of the players after a movement.",
				otherPlayer, game.getCurrentPlayer());
	}

	private void testMovementToEmptyCellWrongTurn(String hero,
			int playerNumber, Point initPosition, Direction direction,
			int step, boolean wrapping) throws Exception {
		testMovementToEmptyCellWrongTurnHelper((Game) createGame(), hero,
				playerNumber, initPosition, direction, step, wrapping);
	}

	private void testMovementToEmptyCellWrongTurnHelper(Game game, String hero,
			int playerNumber, Point initPosition, Direction direction,
			int step, boolean wrapping) throws Exception {
		Field f = Game.class.getDeclaredField("board");
		f.setAccessible(true);
		if (playerNumber == 1)
			game.setCurrentPlayer(game.getPlayer1());
		else
			game.setCurrentPlayer(game.getPlayer2());
		Player currentPlayer = game.getCurrentPlayer();
		Player otherPlayer = game.getPlayer2();
		if (currentPlayer == otherPlayer)
			otherPlayer = game.getPlayer1();

		Piece piece = createPiece(convertPathtoChar(hero), currentPlayer, game);
		Point newPosition = getFinalDestination(initPosition, direction, step,
				wrapping);
		game = clearAndInsert(game, new Object[][] { { initPosition.x,
				initPosition.y, piece } });
		Cell[][] board = (Cell[][]) f.get(game);

		game.setCurrentPlayer(otherPlayer);

		try {
			piece.move(direction);
			fail("Trying to move in a wrong turn should raise a WrongTurnException.");
		} catch (WrongTurnException e) {
			assertEquals("The posI attribute of the piece is incorrect.",
					initPosition.x, piece.getPosI());
			assertEquals("The posJ attribute of the piece is incorrect.",
					initPosition.y, piece.getPosJ());
			assertEquals("The piece found in the original cell is incorrect.",
					piece, board[initPosition.x][initPosition.y].getPiece());
			assertEquals(
					"The piece found in the destination cell is incorrect.",
					null, board[newPosition.x][newPosition.y].getPiece());
			assertEquals(
					"The game should not switch turn since the movement is invalid.",
					otherPlayer, game.getCurrentPlayer());
		}

	}

	private void testInvalidMovementToEmptyCell(String hero, int playerNumber,
			Point initPosition, Direction direction, int step, boolean wrapping)
			throws Exception {
		testInvalidMovementToEmptyCellHelper((Game) createGame(), hero,
				playerNumber, initPosition, direction, step, wrapping);
	}

	private void testInvalidMovementToEmptyCellHelper(Game game, String hero,
			int playerNumber, Point initPosition, Direction direction,
			int step, boolean wrapping) throws Exception {
		Field f = Game.class.getDeclaredField("board");
		f.setAccessible(true);
		if (playerNumber == 1)
			game.setCurrentPlayer(game.getPlayer1());
		else
			game.setCurrentPlayer(game.getPlayer2());
		Player currentPlayer = game.getCurrentPlayer();
		Piece piece = createPiece(convertPathtoChar(hero), currentPlayer, game);
		Point newPosition = getFinalDestination(initPosition, direction, step,
				wrapping);
		game = clearAndInsert(game, new Object[][] { { initPosition.x,
				initPosition.y, piece } });
		Cell[][] board = (Cell[][]) f.get(game);

		game.setCurrentPlayer(piece.getOwner());

		try {
			piece.move(direction);
			fail("Trying to move in an invalid direction should raise an InvalidMovementException.");
		} catch (InvalidMovementException e) {
			assertEquals("The posI attribute of the piece is incorrect.",
					initPosition.x, piece.getPosI());
			assertEquals("The posJ attribute of the piece is incorrect.",
					initPosition.y, piece.getPosJ());
			assertEquals("The piece found in the original cell is incorrect.",
					piece, board[initPosition.x][initPosition.y].getPiece());
			assertEquals(
					"The piece found in the destination cell is incorrect.",
					null, board[newPosition.x][newPosition.y].getPiece());
			assertEquals(
					"The game should not switch turn since the movement is invalid.",
					currentPlayer, game.getCurrentPlayer());
		}

	}

	private char chooseRandomHero() {
		int random = (int) (Math.random() * 7);
		return convertNumtoChar(random);
	}

	private char convertNumtoChar(int number) {
		switch (number) {
		case 0:
			return 'M';
		case 1:
			return 'A';
		case 2:
			return 'P';
		case 3:
			return 'S';
		case 4:
			return 'T';
		case 5:
			return 'R';
		default:
			return 'K';
		}
	}

	private char convertPathtoChar(String path) {
		switch (path) {
		case medicPath:
			return 'M';
		case armoredPath:
			return 'A';
		case speedsterPath:
			return 'P';
		case superPath:
			return 'S';
		case techPath:
			return 'T';
		case rangedPath:
			return 'R';
		default:
			return 'K';
		}
	}

	private Point[] getTestPositions(int xMin, int xMax, int yMin, int yMax,
			int number) {
		ArrayList<Integer> xIndices = new ArrayList<Integer>();
		for (int i = xMin; i <= xMax; i++)
			xIndices.add(i);
		ArrayList<Integer> yIndices = new ArrayList<Integer>();
		for (int i = yMin; i <= yMax; i++)
			yIndices.add(i);
		Collections.shuffle(xIndices);
		Collections.shuffle(yIndices);
		Point[] result = new Point[number];
		int x = 0;
		int y = 0;
		for (int i = 0; i < number; i++) {
			result[i] = new Point(xIndices.get(x), yIndices.get(y));
			x++;
			y++;
			if (x == xIndices.size()) {
				x = 0;
				Collections.shuffle(xIndices);
			}
			if (y == yIndices.size()) {
				y = 0;
				Collections.shuffle(yIndices);
			}

		}
		return result;
	}

	private Point getFinalDestination(Point pos, Direction d, int step,
			boolean wrapping) {

		Point p = new Point();
		p.x = pos.x;
		p.y = pos.y;
		switch (d) {
		case DOWN:
			p.x += step;
			break;
		case DOWNLEFT:
			p.x += step;
			p.y -= step;
			break;
		case DOWNRIGHT:
			p.x += step;
			p.y += step;
			break;
		case LEFT:
			p.y -= step;
			break;
		case RIGHT:
			p.y += step;
			break;
		case UP:
			p.x -= step;
			break;
		case UPLEFT:
			p.x -= step;
			p.y -= step;
			break;
		case UPRIGHT:
			p.x -= step;
			p.y += step;
			break;

		}

		if (!wrapping)
			return p;
		else {
			p.x += boardHeight;
			p.y += boardWidth;
			p.x %= boardHeight;
			p.y %= boardWidth;
			return p;
		}

	}

	private Piece createPiece(char c, Player p, Game g) {

		Piece r = null;

		switch (c) {
		case 'P':
			r = new Speedster(p, g, "Speedster");
			break;
		case 'S':
			r = new Super(p, g, "Super");
			break;
		case 'T':
			r = new Tech(p, g, "Tech");
			break;
		case 'R':
			r = new Ranged(p, g, "Ranged");
			break;
		case 'A':
			r = new Armored(p, g, "Armored");
			break;

		case 'M':
			r = new Medic(p, g, "Medic");
			break;

		case 'K':
			if (p == g.getPlayer1())
				r = new SideKickP1(g, "SideKickP1");
			if (p == g.getPlayer2())
				r = new SideKickP2(g, "SideKickP2");
			break;

		case 'N':
			r = null;
			break;

		}

		return (r);

	}

	private Game clearAndInsert(Game g, Object[][] insertionDetails)
			throws Exception {

		Field f = Class.forName(gamePath).getDeclaredField("board");
		f.setAccessible(true);

		Cell[][] board = new Cell[g.getBoardHeight()][g.getBoardWidth()];
		for (int i = 0; i < board.length; i++) {
			for (int j = 0; j < board[i].length; j++) {
				board[i][j] = new Cell();
			}
		}

		for (int i = 0; i < insertionDetails.length; i++) {

			if (insertionDetails[i].length == 3) {

				int x = (int) insertionDetails[i][0];
				int y = (int) insertionDetails[i][1];
				Piece p = (Piece) insertionDetails[i][2];
				board[x][y] = new Cell(p);
				if (p != null) {
					p.setPosI(x);
					p.setPosJ(y);
				}

			}

		}

		f.set(g, board);
		return g;

	}

	private Object createGame() throws NoSuchMethodException,
			SecurityException, ClassNotFoundException, InstantiationException,
			IllegalAccessException, IllegalArgumentException,
			InvocationTargetException {
		Constructor<?> gameConstructor = Class.forName(gamePath)
				.getConstructor(Class.forName(playerPath),
						Class.forName(playerPath));

		Constructor<?> playerConstructor = Class.forName(playerPath)
				.getConstructor(String.class);

		int random = (int) (Math.random() * 40) + 10;
		Object p1 = playerConstructor.newInstance("Player_" + random);
		random = (int) (Math.random() * 40) + 10;
		Object p2 = playerConstructor.newInstance("Player_" + random);

		Object g = gameConstructor.newInstance(p1, p2);
		return g;
	}

	private ArrayList<Piece> preparePieces(char p1, char p2, Direction d,
			boolean isP1, boolean testWrapping, boolean armorRaised, Game g)
			throws Exception {
		int randomI = 0;
		int randomJ = 0;

		if (!testWrapping) {
			if (d == Direction.UP || d == Direction.UPRIGHT
					|| d == Direction.UPLEFT)
				randomI = ((int) (Math.random() * (g.getBoardHeight() - 1))) + 1;
			else if (d == Direction.DOWN || d == Direction.DOWNRIGHT
					|| d == Direction.DOWNLEFT)
				randomI = (int) (Math.random() * (g.getBoardHeight() - 1));
			else
				randomI = (int) (Math.random() * g.getBoardHeight());
			if (d == Direction.RIGHT || d == Direction.UPRIGHT
					|| d == Direction.DOWNRIGHT)
				randomJ = (int) (Math.random() * (g.getBoardWidth() - 1));
			else if (d == Direction.LEFT || d == Direction.UPLEFT
					|| d == Direction.DOWNLEFT)
				randomJ = ((int) (Math.random() * (g.getBoardWidth() - 1))) + 1;
			else
				randomJ = (int) (Math.random() * g.getBoardWidth());
		} else {
			if (d == Direction.UP)
				randomI = 0;
			else if (d == Direction.DOWN)
				randomI = g.getBoardHeight() - 1;
			else
				randomI = (int) (Math.random() * g.getBoardHeight());
			if (d == Direction.LEFT)
				randomJ = 0;
			else if (d == Direction.RIGHT)
				randomJ = g.getBoardWidth() - 1;
			else {
				if ((d == Direction.UPRIGHT && randomI != 0)
						|| (d == Direction.DOWNRIGHT && randomI != g
								.getBoardHeight() - 1))
					randomJ = g.getBoardWidth() - 1;
				else if ((d == Direction.UPLEFT && randomI != 0)
						|| (d == Direction.DOWNLEFT && randomI != g
								.getBoardHeight() - 1))
					randomJ = 0;
				else
					randomJ = (int) (Math.random() * g.getBoardWidth());

			}

		}
		Piece p = null;
		if (isP1)
			p = createPiece(p1, g.getPlayer1(), g, true);
		else
			p = createPiece(p1, g.getPlayer2(), g, true);
		p.setPosI(randomI);
		p.setPosJ(randomJ);
		Piece t = null;
		if (isP1)
			t = createPiece(p2, g.getPlayer2(), g, false);
		else
			t = createPiece(p2, g.getPlayer1(), g, false);
		if (p2 == 'A' && !armorRaised)
			((Armored) t).setArmorUp(false);
		int i2 = randomI;
		int j2 = randomJ;
		if (d == Direction.UP || d == Direction.UPRIGHT
				|| d == Direction.UPLEFT)
			i2 = i2 - 1;
		else if (d == Direction.DOWN || d == Direction.DOWNRIGHT
				|| d == Direction.DOWNLEFT)
			i2 = i2 + 1;
		if (i2 < 0)
			i2 = g.getBoardHeight() - 1;
		else if (i2 >= g.getBoardHeight())
			i2 = 0;
		t.setPosI(i2);
		if (d == Direction.RIGHT || d == Direction.UPRIGHT
				|| d == Direction.DOWNRIGHT)
			j2 = j2 + 1;
		else if (d == Direction.LEFT || d == Direction.UPLEFT
				|| d == Direction.DOWNLEFT)
			j2 = j2 - 1;
		if (j2 < 0)
			j2 = g.getBoardWidth() - 1;
		else if (j2 >= g.getBoardWidth())
			j2 = 0;
		t.setPosJ(j2);

		clearBoardAndInsert(g, p, randomI, randomJ, t, i2, j2);
		if (isP1)
			g.setCurrentPlayer(g.getPlayer1());
		else
			g.setCurrentPlayer(g.getPlayer2());

		ArrayList<Piece> res = new ArrayList<Piece>();
		res.add(p);
		res.add(t);
		return res;
	}

	private void attackAndCheck(String pieces, String targets, boolean isP1,
			boolean testWrapping, boolean armorRaised, Game g,
			ArrayList<Integer> checks) throws Exception {
		for (int i = 0; i < pieces.length(); i++) {
			for (int j = 0; j < targets.length(); j++) {
				int r = ((int) (Math.random() * 8)) + 1;
				Direction d = getDirectionFromNumber(r);
				ArrayList<Piece> res = preparePieces(pieces.charAt(i),
						targets.charAt(j), d, isP1, testWrapping, armorRaised,
						g);
				winCalled = false;
				if (isP1) {
					g.getPlayer1().setPayloadPos(0);
					if (checks.contains(9))
						g.getPlayer1().setSideKilled(0);
					if (checks.contains(10))
						g.getPlayer1().setSideKilled(1);
					g.getPlayer2().getDeadCharacters().clear();
				} else {
					g.getPlayer2().setPayloadPos(0);
					if (checks.contains(9))
						g.getPlayer2().setSideKilled(0);
					if (checks.contains(10))
						g.getPlayer2().setSideKilled(1);
					g.getPlayer1().getDeadCharacters().clear();
				}
				int pi = res.get(0).getPosI();
				int pj = res.get(0).getPosJ();
				int ti = res.get(1).getPosI();
				int tj = res.get(1).getPosJ();
				res.get(0).attack(res.get(1));
				String pOwner = "";
				if (isP1)
					pOwner = "player one";
				else
					pOwner = "player two";

				String firstPart = "If " + pOwner + "'s "
						+ getPieceName(pieces.charAt(i))
						+ " located at position (" + pi + "," + pj
						+ ") is attacking an enemy "
						+ getPieceName(targets.charAt(j));
				if (targets.charAt(j) == 'A') {
					if (armorRaised)
						firstPart += " which has his armor up";
					else
						firstPart += " which has his armor down";
				}
				if (checks.contains(1)) {
					assertTrue(
							firstPart
									+ ", the checkWinner method should be invoked on its game instance variable.",
							winCalled);
				}
				if (checks.contains(2)) {
					assertFalse(
							firstPart
									+ ", the checkWinner method should not be invoked on its game instance variable.",
							winCalled);
				}
				if (checks.contains(3)) {
					boolean isDead = false;
					if (isP1)
						isDead = g.getPlayer2().getDeadCharacters()
								.contains(res.get(1));
					else
						isDead = g.getPlayer1().getDeadCharacters()
								.contains(res.get(1));
					assertTrue(
							firstPart
									+ ", the attacked "
									+ getPieceName(targets.charAt(j))
									+ " should be added to its owner's dead characters list.",
							isDead);
				}
				if (checks.contains(4)) {
					boolean isDead = false;
					if (isP1)
						isDead = g.getPlayer2().getDeadCharacters()
								.contains(res.get(1));
					else
						isDead = g.getPlayer1().getDeadCharacters()
								.contains(res.get(1));
					assertFalse(
							firstPart
									+ ", the attacked "
									+ getPieceName(targets.charAt(j))
									+ " should not be added to its owner's dead characters list.",
							isDead);
				}
				if (checks.contains(5)) {
					Armored a = (Armored) res.get(1);
					assertEquals(
							firstPart
									+ ", the enemy armored's armorUp attribute should be set to false.",
							false, a.isArmorUp());

				}
				if (checks.contains(6)) {
					assertEquals(
							firstPart
									+ ", the attack method should not remove the enemy's armored piece from the board therefore, it should remain in its original position on the board.",
							res.get(1), g.getCellAt(ti, tj).getPiece());
					assertEquals(
							firstPart
									+ ", the attack method should not remove the enemy's armored piece from the board therefore, the armored's posI attibute should not change.",
							ti, res.get(1).getPosI());
					assertEquals(
							firstPart
									+ ", the attack method should not remove the enemy's armored piece from the board therefore, the armored's posJ attibute should not change.",
							tj, res.get(1).getPosJ());
				}
				if (checks.contains(7)) {
					assertEquals(
							firstPart
									+ ", the attack method should remove the enemy's armored piece from the board therefore, the removed armored's position on the board should be empty.",
							null, g.getCellAt(ti, tj).getPiece());
				}
				if (checks.contains(8)) {
					Player current = null;
					if (isP1)
						current = g.getPlayer1();
					else
						current = g.getPlayer2();
					assertEquals(firstPart + " and eliminates it, the "
							+ pOwner + "'s payLoad should move one step.", 1,
							current.getPayloadPos());
				}
				if (checks.contains(9)) {
					Player current = null;
					if (isP1)
						current = g.getPlayer1();
					else
						current = g.getPlayer2();

					assertEquals(
							firstPart
									+ " and it was its first eliminated side kick, the "
									+ pOwner
									+ "'s sideKilled attribute should be increased by one.",
							1, current.getSideKilled());
					assertEquals(
							firstPart
									+ " and it was its first eliminated side kick, the "
									+ pOwner + "'s payLoad should not move.",
							0, current.getPayloadPos());
				}
				if (checks.contains(10)) {
					Player current = null;
					if (isP1)
						current = g.getPlayer1();
					else
						current = g.getPlayer2();
					assertEquals(
							firstPart
									+ " and it was its second eliminated side kick, the "
									+ pOwner
									+ "'s payLoad should move one step.", 1,
							current.getPayloadPos());
				}
				if (checks.contains(11)) {
					assertEquals(
							firstPart
									+ ", the "
									+ getPieceName(pieces.charAt(i))
									+ " should not move therefore, it should remain in its original position on the board.",
							res.get(0), g.getCellAt(pi, pj).getPiece());
					assertEquals(
							firstPart + ", the "
									+ getPieceName(pieces.charAt(i))
									+ " should not move therefore, the "
									+ getPieceName(pieces.charAt(i))
									+ "'s posI attibute should not change.",
							pi, res.get(0).getPosI());
					assertEquals(
							firstPart + ", the "
									+ getPieceName(pieces.charAt(i))
									+ " should not move therefore, the "
									+ getPieceName(pieces.charAt(i))
									+ "'s posJ attibute should not change.",
							pj, res.get(0).getPosJ());
				}
			}
		}
	}

	private void moveAndAttack(String pieces, String targets, Direction d,
			boolean isP1, boolean testWrapping, boolean armorRaised, Game g,
			ArrayList<Integer> checks) throws Exception {
		for (int i = 0; i < pieces.length(); i++) {
			for (int j = 0; j < targets.length(); j++) {
				ArrayList<Piece> res = preparePieces(pieces.charAt(i),
						targets.charAt(j), d, isP1, testWrapping, armorRaised,
						g);
				int pi = res.get(0).getPosI();
				int pj = res.get(0).getPosJ();
				int ti = res.get(1).getPosI();
				int tj = res.get(1).getPosJ();
				String firstPart = getFirstPart(pieces.charAt(i),
						targets.charAt(j), res.get(0).getPosI(), res.get(0)
								.getPosJ(), (isP1 ? "player 1" : "player 2"), d);
				attackMethodCalled = false;
				switchCalled = false;
				winCalled = false;
				target = null;
				res.get(0).move(d);
				if (targets.charAt(j) == 'A') {
					if (armorRaised)
						firstPart += " which has his armor up";
					else
						firstPart += " which has his armor down";
				}
				if (checks.contains(1)) {
					assertTrue(firstPart
							+ ", the attack method should be invoked on  "
							+ getPieceName(pieces.charAt(i)) + ".",
							attackMethodCalled);

				}
				if (checks.contains(2)) {
					assertEquals(
							firstPart
									+ ", the attack method should be invoked on "
									+ getPieceName(pieces.charAt(i))
									+ " with the attacked "
									+ getPieceName(targets.charAt(j))
									+ " as its parameter.", res.get(1), target);
				}
				if (checks.contains(3)) {
					assertEquals(
							firstPart
									+ ", the "
									+ getPieceName(pieces.charAt(i))
									+ "'s original position on the board should be empty.",
							null, (g.getCellAt(pi, pj)).getPiece());
				}
				if (checks.contains(4)) {
					assertEquals(
							firstPart
									+ ", the "
									+ getPieceName(pieces.charAt(i))
									+ " should be contained in the cell it moved to.",
							res.get(0), g.getCellAt(ti, tj).getPiece());
				}

				if (checks.contains(5)) {
					assertEquals(
							firstPart
									+ ", the "
									+ getPieceName(pieces.charAt(i))
									+ "'s posI attribute should "
									+ ((d == Direction.LEFT || d == Direction.RIGHT) ? "not "
											: "")
									+ "be changed"
									+ (!(d == Direction.LEFT || d == Direction.RIGHT) ? "correctly."
											: "."), ti, res.get(0).getPosI());
				}
				if (checks.contains(6)) {
					assertEquals(
							firstPart
									+ ", the "
									+ getPieceName(pieces.charAt(i))
									+ "'s posJ attribute should "
									+ ((d == Direction.UP || d == Direction.DOWN) ? "not "
											: "")
									+ "be changed"
									+ (!(d == Direction.UP || d == Direction.DOWN) ? "correctly."
											: "."), tj, res.get(0).getPosJ());
				}
				if (checks.contains(7)) {

					assertTrue(
							firstPart
									+ ", the "
									+ getPieceName(pieces.charAt(i))
									+ " should invoke the switchTurns method on its game instance variable.",
							switchCalled);

				}
				if (checks.contains(8)) {
					assertEquals(
							firstPart
									+ ", the enemy's armored piece should not be removed from the board therefore, it should remain in its original position.",
							res.get(1), g.getCellAt(ti, tj).getPiece());
					assertEquals(
							firstPart

									+ " the "
									+ getPieceName(pieces.charAt(i))
									+ " should not move and remain on its original position on the board.",
							res.get(0), g.getCellAt(pi, pj).getPiece());
				}
				if (checks.contains(9)) {
					assertEquals(
							firstPart
									+ "the enemy's armored piece should not be removed from the board therefore, its posI attribute should not change.",
							ti, res.get(1).getPosI());
					assertEquals(
							firstPart
									+ "the enemy's armored piece should not be removed from the board therefore, its posJ attribute should not change.",
							tj, res.get(1).getPosJ());
					assertEquals(
							firstPart

									+ " the "
									+ getPieceName(pieces.charAt(i))
									+ " should not move and remain on its original position on the board therefore, its posI attribute should not change.",
							pi, res.get(0).getPosI());
					assertEquals(
							firstPart

									+ " the "
									+ getPieceName(pieces.charAt(i))
									+ " should not move and remain on its original position on the board therefore, its posJ attribute should not change.",
							pj, res.get(0).getPosJ());
				}
				if (checks.contains(10)) {
					assertEquals(
							firstPart
									+ ",  the "
									+ getPieceName(pieces.charAt(i))
									+ " should move according to the direction therefore, it should be contained in the new position on the board.",
							res.get(0), g.getCellAt(ti, tj).getPiece());
				}

			}
		}
	}

	private Direction getDirectionFromNumber(int i) {
		Direction d = null;
		switch (i) {
		case 1:
			d = Direction.UP;
			break;
		case 2:
			d = Direction.DOWN;
			break;
		case 3:
			d = Direction.RIGHT;
			break;
		case 4:
			d = Direction.LEFT;
			break;
		case 5:
			d = Direction.UPRIGHT;
			break;
		case 6:
			d = Direction.UPLEFT;
			break;
		case 7:
			d = Direction.DOWNRIGHT;
			break;
		case 8:
			d = Direction.DOWNLEFT;
			break;
		}
		return d;
	}

	private String getFirstPart(char p1, char p2, int i, int j, String pOwner,
			Direction d) {
		String firstPart = "If " + pOwner + "'s " + getPieceName(p1)
				+ " located at position (" + i + "," + j + ") is moving "
				+ getDirectionName(d) + " toward an enemy " + getPieceName(p2);
		return firstPart;
	}

	private String getPieceName(char c) {
		String res = "";
		switch (c) {
		case 'P':
			res = "Speedster";
			break;
		case 'S':
			res = "Super";
			break;
		case 'T':
			res = "Tech";
			break;
		case 'R':
			res = "Ranged";
			break;
		case 'A':
			res = "Armored";
			break;
		case 'M':
			res = "Medic";
			break;
		case 'K':
			res = "SideKick";
			break;
		}
		return res;
	}

	private String getDirectionName(Direction d) {
		String res = "";
		if (d == Direction.UP)
			res = "up";
		else if (d == Direction.DOWN)
			res = "down";
		else if (d == Direction.LEFT)
			res = "left";
		else if (d == Direction.RIGHT)
			res = "right";
		else if (d == Direction.UPRIGHT)
			res = "up right";
		else if (d == Direction.UPLEFT)
			res = "up left";
		else if (d == Direction.DOWNRIGHT)
			res = "down right";
		else if (d == Direction.DOWNLEFT)
			res = "down left";
		return res;
	}

	private void clearBoardAndInsert(Game g, Piece p, int i1, int j1, Piece t,
			int i2, int j2) throws Exception {
		Field f = Class.forName(gamePath).getDeclaredField("board");
		f.setAccessible(true);

		Cell[][] board = new Cell[g.getBoardHeight()][g.getBoardWidth()];
		for (int i = 0; i < board.length; i++) {
			for (int j = 0; j < board[i].length; j++) {
				board[i][j] = new Cell();
			}

			board[i1][j1] = new Cell(p);
			board[i2][j2] = new Cell(t);
			f.set(g, board);
		}

	}

	private Game createGame(int i) {

		int random = (int) (Math.random() * 40) + 10;
		Player p1 = new Player("Player_" + random);
		random = (int) (Math.random() * 40) + 10;
		Player p2 = new Player("Player_" + random);
		Game g = null;
		if (i == 1) {
			g = new Game(p1, p2) {
				@Override
				public void switchTurns() {
					switchCalled = true;
				}
			};
		} else if (i == 2) {
			g = new Game(p1, p2) {
				@Override
				public boolean checkWinner() {
					winCalled = true;
					return false;
				}
			};
		} else
			g = new Game(p1, p2);
		return g;
	}

	private Piece createPiece(char c, Player p, Game g, boolean attack) {

		Piece r = null;

		switch (c) {
		case 'P': {
			if (!attack)
				r = new Speedster(p, g, "Speedster");
			else
				r = new Speedster(p, g, "Speedster") {
					@Override
					public void attack(Piece p) {
						attackMethodCalled = true;
						target = p;
						super.attack(p);
					}
				};
		}
			break;
		case 'S': {
			if (!attack)
				r = new Super(p, g, "Super");
			else
				r = new Super(p, g, "Super") {
					@Override
					public void attack(Piece p) {
						attackMethodCalled = true;
						target = p;
						super.attack(p);
					}
				};
		}
			break;
		case 'T': {
			if (!attack)
				r = new Tech(p, g, "Tech");
			else
				r = new Tech(p, g, "Tech") {
					@Override
					public void attack(Piece p) {
						attackMethodCalled = true;
						target = p;
						super.attack(p);
					}
				};
		}
			break;
		case 'R': {
			if (!attack)
				r = new Ranged(p, g, "Ranged");
			else
				r = new Ranged(p, g, "Ranged") {
					@Override
					public void attack(Piece p) {
						attackMethodCalled = true;
						target = p;
						super.attack(p);
					}
				};
		}
			break;

		case 'A': {
			if (!attack)
				r = new Armored(p, g, "Armored");
			else
				r = new Armored(p, g, "Armored") {
					@Override
					public void attack(Piece p) {
						attackMethodCalled = true;
						target = p;
						super.attack(p);
					}
				};
		}
			break;

		case 'M': {
			if (!attack)
				r = new Medic(p, g, "Medic");
			else
				r = new Medic(p, g, "Medic") {
					@Override
					public void attack(Piece p) {
						attackMethodCalled = true;
						target = p;
						super.attack(p);
					}
				};
		}
			break;

		case 'K':
			if (p == g.getPlayer1()) {
				if (!attack)
					r = new SideKickP1(g, "SideKickP1");
				else
					r = new SideKickP1(g, "SideKickP1") {
						@Override
						public void attack(Piece p) {
							attackMethodCalled = true;
							target = p;
							super.attack(p);
						}
					};
			}
			if (p == g.getPlayer2()) {
				if (!attack)
					r = new SideKickP2(g, "SideKickP2");
				else
					r = new SideKickP2(g, "SideKickP2") {
						@Override
						public void attack(Piece p) {
							attackMethodCalled = true;
							target = p;
							super.attack(p);
						}
					};
			}
			break;

		case 'N':
			r = null;
			break;

		}

		return (r);

	}

}
