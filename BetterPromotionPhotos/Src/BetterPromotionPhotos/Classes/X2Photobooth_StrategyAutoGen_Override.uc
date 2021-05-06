class X2Photobooth_StrategyAutoGen_Override extends X2Photobooth_StrategyAutoGen;

function TakePhoto() // Function Override
{
	local XComGameState_Unit Unit;
	local XComGameState_AdventChosen ChosenState;
	local SoldierBond BondData;
	local StateObjectReference BondmateRef;

	// Set things up for the next photo and queue it up to the photobooth.
	if (arrAutoGenRequests.Length > 0)
	{
		ExecutingAutoGenRequest = arrAutoGenRequests[0];

		AutoGenSettings.PossibleSoldiers.Length = 0;
		AutoGenSettings.PossibleSoldiers.AddItem(ExecutingAutoGenRequest.UnitRef);
		AutoGenSettings.TextLayoutState = ExecutingAutoGenRequest.TextLayoutState;
		AutoGenSettings.HeadShotAnimName = '';
		AutoGenSettings.CameraPOV.FOV = class'UIArmory_Photobooth'.default.m_fCameraFOV;
		AutoGenSettings.BackgroundDisplayName = class'UIPhotoboothBase'.default.m_strEmptyOption;
		SetFormation("Solo");

		switch (ExecutingAutoGenRequest.TextLayoutState)
		{
		case ePBTLS_DeadSoldier:
			AutoGenSettings.CameraPresetDisplayName = "Full Frontal";
			break;
		case ePBTLS_PromotedSoldier:
			AutoGenSettings.CameraPresetDisplayName = "Full Frontal";
			AutoGenSettings.BackgroundDisplayName = GetXCOMBackgroundName(); // Add random XCOM background poster
			`PHOTOBOOTH.SetBackgroundColorOverride(false); // Stop background always being black and white
			break;
		case ePBTLS_BondedSoldier:
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ExecutingAutoGenRequest.UnitRef.ObjectID));

			if (Unit.HasSoldierBond(BondmateRef, BondData))
			{
				AutoGenSettings.PossibleSoldiers.AddItem(BondmateRef);
				AutoGenSettings.CameraPresetDisplayName = "Full Frontal";

				SetFormation("Duo");
			}
			else
			{
				arrAutoGenRequests.Remove(0, 1);
				return;
			}
			break;
		case ePBTLS_CapturedSoldier:
			AutoGenSettings.CameraPresetDisplayName = "Captured";

			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ExecutingAutoGenRequest.UnitRef.ObjectID));
			ChosenState = XComGameState_AdventChosen(`XCOMHISTORY.GetGameStateForObjectID(Unit.ChosenCaptorRef.ObjectID));
			AutoGenSettings.BackgroundDisplayName = GetChosenBackgroundName(ChosenState);
			break;
		case ePBTLS_HeadShot:
			AutoGenSettings.CameraPresetDisplayName = "Headshot";
			AutoGenSettings.SizeX = ExecutingAutoGenRequest.SizeX;
			AutoGenSettings.SizeY = ExecutingAutoGenRequest.SizeY;
			AutoGenSettings.CameraDistance = ExecutingAutoGenRequest.CameraDistance;
			AutoGenSettings.HeadShotAnimName = ExecutingAutoGenRequest.AnimName;
			AutoGenSettings.CameraPOV.FOV = 80;
			break;
		}

		`PHOTOBOOTH.SetAutoGenSettings(AutoGenSettings, PhotoTaken);
	}
	else
	{
		m_bTakePhotoRequested = false;
		Cleanup();
	}
}

static function string GetXCOMBackgroundName() { // Fetch a random localized BackgroundDisplayName

	local string BackgroundName;
	local array<BackgroundPosterOptions> arrBackgrounds;
	local int BackgroundIndex;

	`PHOTOBOOTH.GetBackgrounds(arrBackgrounds, ePBT_XCOM);

	BackgroundIndex = `SYNC_RAND_STATIC(arrBackgrounds.length);
	BackgroundName = arrBackgrounds[BackgroundIndex].BackgroundDisplayName;

	return BackgroundName;

}