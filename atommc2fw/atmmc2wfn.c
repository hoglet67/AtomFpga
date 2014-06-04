#include "atmmc2.h"

#include <string.h>
#include "atmmc2io.h"
#include "atmmc2def.h"
#include "diskio.h"
#include "ff.h"
#include "wildcard.h"

BYTE res;

BYTE globalIndex;
WORD globalAmount;
BYTE globalDataPresent;
BYTE rwmode;

DIR dir;
FIL fil;
FILINFO filinfo;
FATFS fatfs;

extern BYTE windowData[];

#define WILD_LEN	16

char	WildPattern[WILD_LEN+1];

#ifdef INCLUDE_SDDOS

extern BYTE sectorData[];

DWORD sectorInBuffer = 0xffffffff;

imgInfo driveInfo[4];

BYTE globalCurDrive;
DWORD globalLBAOffset;

#endif


// use only immediately after open
extern void get_fileinfo_special(FILINFO *);




void at_initprocessor(void)
{
   rwmode = 0;

   fatfs.win = windowData;

#ifdef INCLUDE_SDDOS
   memset(&driveInfo[0], 0xff, sizeof(imgInfo)*4);
#endif

  f_chdrive(0);
  f_mount(0, &fatfs);
}


void GetWildcard(void)
{
	int	Idx			= 0;
	int	WildPos		= -1;
	int	LastSlash	= -1;
	
	//log0("GetWildcard() %s\n",(const char *)globalData);
	
	while ((Idx<strlen((const char*)globalData)) && (WildPos<0)) 
	{
		// Check for wildcard character
		if((globalData[Idx]=='?') || (globalData[Idx]=='*')) 
			WildPos=Idx;

		// Check for path seperator
		if((globalData[Idx]=='\\') || (globalData[Idx]=='/'))
			LastSlash=Idx;
			
		Idx++;
	}
	
	//log0("GetWildcard() Idx=%d, WildPos=%d, LastSlash=%d\n",Idx,WildPos,LastSlash);
	
	if(WildPos>-1)
	{
		if(LastSlash>-1)
		{
			// Path followed by wildcard
			// Terminate dir filename at last slash and copy wildcard
			globalData[LastSlash]=0x00;
			strncpy(WildPattern,(const char*)&globalData[LastSlash+1],WILD_LEN);
		}
		else
		{
			// Wildcard on it's own
			// Copy wildcard, then set path to null
			strncpy(WildPattern,(const char*)globalData,WILD_LEN);
			globalData[0]=0x00;
		}
	}
	else
	{
		// No wildcard, show all files
#if (PLATFORM==PLATFORM_PIC)
		strcpypgm2ram((char*)&WildPattern[0], (const rom far char*)"*");
#elif (PLATFORM==PLATFORM_AVR)
		strncpy_P(WildPattern,PSTR("*"),WILD_LEN);
#endif
	}
	
	//log0("GetWildcard() globalData=%s WildPattern=%s\n",(const char*)globalData,WildPattern); 
}

void wfnDirectoryOpen(void)
{
	// Separate wildcard and path 
	GetWildcard();
   
	res = f_opendir(&dir, (const char*)globalData);
   if (FR_OK != res)
   {
      WriteDataPort(STATUS_COMPLETE | res);
      return;
   }

   WriteDataPort(STATUS_OK);
}




void wfnDirectoryRead(void)
{
   char len;
	int	Match;

	while (1)
	{
		char n = 0;

		res = f_readdir(&dir, &filinfo);
		if (res != FR_OK || !filinfo.fname[0])
		{
			// done
			WriteDataPort(STATUS_COMPLETE | res);
			return;
		}

		// Check to see if filename matches current wildcard
		//
		Match=wildcmp(WildPattern,filinfo.fname);
		//log0("WildPattern=%s, filinfo.fname=%s, Match=%d\n",WildPattern,filinfo.fname,Match);
		if(Match)
		{
			len = (char)strlen(filinfo.fname);

			if (filinfo.fattrib & AM_DIR)	
			{
				n = 1;
				globalData[0] = '<';
			}

			strcpy((char*)&globalData[n], (const char*)filinfo.fname);

			if (filinfo.fattrib & AM_DIR)
			{
				globalData[len+1] = '>';
				globalData[len+2] = 0;
				len += 2; // brackets
			}

			// just for giggles put the attribute & filesize in the buffer
			//
			globalData[len+1] = filinfo.fattrib;
			memcpy(&globalData[len+2], (void*)(&filinfo.fsize), sizeof(DWORD));

			WriteDataPort(STATUS_OK);
			return;
		}
	}

#if 0
   while (1)
   {
      char n = 0;

      res = f_readdir(&dir, &filinfo);
      if (res != FR_OK || !filinfo.fname[0])
      {
         // done
         WriteDataPort(STATUS_COMPLETE | res);
         return;
      }

      // no LFNs here ;)
      //
      len = (char)strlen(filinfo.fname);

      if (filinfo.fattrib & AM_DIR)
      {
         n = 1;
         globalData[0] = '<';
      }

      strcpy((char*)&globalData[n], (const char*)filinfo.fname);

      if (filinfo.fattrib & AM_DIR)
      {
         globalData[len+1] = '>';
         globalData[len+2] = 0;
         len += 2; // brackets
      }

      // just for giggles put the attribute & filesize in the buffer
      //
      globalData[len+1] = filinfo.fattrib;
      memcpy(&globalData[len+2], (void*)(&filinfo.fsize), sizeof(DWORD));

      WriteDataPort(STATUS_OK);
      return;
   }
#endif
}



void wfnSetCWDirectory(void)
{
   WriteDataPort(STATUS_COMPLETE | f_chdir((const XCHAR*)globalData));
}




static BYTE fileOpen(BYTE mode)
{
   return 0x40 | f_open(&fil, (const char*)globalData, mode);
}

void wfnFileOpenRead(void)
{
   res = fileOpen(FA_OPEN_EXISTING|FA_READ);
   get_fileinfo_special(&filinfo);
   WriteDataPort(STATUS_COMPLETE | res);
}

void wfnFileOpenWrite(void)
{
   WriteDataPort(STATUS_COMPLETE | fileOpen(FA_CREATE_NEW|FA_WRITE));
}





void wfnFileGetInfo(void)
{
   union
   {
      DWORD dword;
      char byte[4];
   }
   dwb;

   dwb.dword = fil.fsize;
   globalData[0] = dwb.byte[0];
   globalData[1] = dwb.byte[1];
   globalData[2] = dwb.byte[2];
   globalData[3] = dwb.byte[3];

   dwb.dword = (DWORD)(fil.org_clust-2) * fatfs.csize + fatfs.database;
   globalData[4] = dwb.byte[0];
   globalData[5] = dwb.byte[1];
   globalData[6] = dwb.byte[2];
   globalData[7] = dwb.byte[3];

   dwb.dword = fil.fptr;
   globalData[8] = dwb.byte[0];
   globalData[9] = dwb.byte[1];
   globalData[10] = dwb.byte[2];
   globalData[11] = dwb.byte[3];

   globalData[12] = filinfo.fattrib & 0x3f;

   WriteDataPort(STATUS_OK);
}




void wfnFileRead(void)
{
   UINT read;
   if (globalAmount == 0)
   {
      globalAmount = 256;
   }

   WriteDataPort(STATUS_COMPLETE | f_read(&fil, globalData, globalAmount, &read));
}




void wfnFileWrite(void)
{
   UINT written;
   if (globalAmount == 0)
   {
      globalAmount = 256;
   }

   WriteDataPort(STATUS_COMPLETE | f_write(&fil, (void*)globalData, globalAmount, &written));
}




void wfnFileClose(void)
{
   WriteDataPort(STATUS_COMPLETE | f_close(&fil));
}






void wfnFileDelete(void)
{
   WriteDataPort(STATUS_COMPLETE | f_unlink((const XCHAR*)&globalData[0]));
}


#ifdef INCLUDE_SDDOS


BYTE tryOpenImage(imgInfo* imginf)
{
   BYTE i;

   res = f_open(&fil, (const XCHAR*)&imginf->filename,FA_READ);
   if (FR_OK != res)
   {
      return STATUS_COMPLETE | res;
   }

   // see pff clust2sec()
   //
   imginf->baseSector = (DWORD)(fil.org_clust-2) * fatfs.csize + fatfs.database;

   // disallow multiple mounts of the same image
   //
   for (i = 0; i < 4; ++i)
   {
      if (imginf == &driveInfo[i])
      {
         continue;
      }

      if (memcmp((void*)imginf, (void*)&driveInfo[i], sizeof(imgInfo)) == 0)
      {
         // warning - already mounted
         return STATUS_COMPLETE + ERROR_ALREADY_MOUNT; // 0x4a;
      }
   }

   // all good - should only call "get_fileinfo_special" if no other file operations
   // have occurred since the last open.
   //
   get_fileinfo_special(&filinfo);
   imginf->attribs = filinfo.fattrib;

   return imginf->attribs;
}



void saveDrivesImpl(void)
{
#if (PLATFORM==PLATFORM_PIC)
   strcpypgm2ram((char*)&globalData[0], (const rom far char*)"BOOTDRV.CFG");
#elif (PLATFORM==PLATFORM_AVR)
	strcpy_P((char*)&globalData[0],PSTR("BOOTDRV.CFG"));
#endif
   res = f_open(&fil, (const XCHAR*)globalData, FA_OPEN_ALWAYS|FA_WRITE);
   if (FR_OK == res)
   {
      UINT temp;
      f_write(&fil, (const void*)&driveInfo[0], 4 * sizeof(imgInfo), &temp);
      f_close(&fil);
   }
}


void wfnOpenSDDOSImg(void)
{
   // globalData[0] = drive number 0..3
   // globalData[1]... image filename

   BYTE stat, error;
   BYTE id = globalData[0] & 3;

   imgInfo* image = &driveInfo[id];
   stat = image->attribs;

   memset(image, 0, sizeof(imgInfo));
   strncpy((char*)&image->filename, (const char*)&globalData[1], 13);

   error = tryOpenImage(image);
   if (error >= STATUS_COMPLETE)
   {
      // fatal error range
      //
      memset(image, 0xff, sizeof(imgInfo));
   }

   // always save - even if there was an error
   // we may have nullified a previously valid slot.
   //
   saveDrivesImpl();

   WriteDataPort(error);
}


void wfnReadSDDOSSect(void)
{
   BYTE returnCode = STATUS_COMPLETE | ERROR_INVALID_DRIVE;

   if (driveInfo[globalCurDrive].attribs != 0xff)
   {
      // each physical device sector holds 2 sddos sectors
      //
      DWORD sector = driveInfo[globalCurDrive].baseSector + globalLBAOffset / 2;

      returnCode = RES_OK;

      if (sector != sectorInBuffer)
      {
         // cache the physical sectors
         //
         returnCode = disk_read(0, sectorData, sector, 1);
      }

      if (RES_OK == returnCode)
      {
         sectorInBuffer = sector;

         memcpy((void*)globalData, (const void*)(&sectorData[(globalLBAOffset & 1) * 256]), 256);

         WriteDataPort(STATUS_OK);
         return;
      }

      driveInfo[globalCurDrive].attribs = 0xff;
      returnCode |= STATUS_COMPLETE;
   }

   WriteDataPort(returnCode);
}




void wfnWriteSDDOSSect(void)
{
   BYTE returnCode = STATUS_COMPLETE | ERROR_INVALID_DRIVE;

   if (driveInfo[globalCurDrive].attribs != 0xff)
   {
      DWORD sector;

      if (driveInfo[globalCurDrive].attribs & 1)
      {
         // read-only
         //
         WriteDataPort(STATUS_COMPLETE | ERROR_READ_ONLY);
         return;
      }

      returnCode = RES_OK;

      sector = driveInfo[globalCurDrive].baseSector + globalLBAOffset / 2;
      if (sector != sectorInBuffer)
      {
         // cache the physical sectors if necessary
         //
         returnCode = disk_read(0, sectorData, sector, 1);
      }

      if (RES_OK == returnCode)
      {
         memcpy((void*)(&sectorData[(globalLBAOffset & 1) * 256]), (const void*)globalData, 256);

         returnCode = disk_write(0, sectorData, sector, 1);
      }

      if (RES_OK == returnCode)
      {
         WriteDataPort(STATUS_OK);
         return;
      }

      driveInfo[globalCurDrive].attribs = 0xff;
      returnCode |= STATUS_COMPLETE;
   }

   WriteDataPort(returnCode);
}


void wfnValidateSDDOSDrives(void)
{
   BYTE i;
   BYTE* ii = (BYTE*)driveInfo;

   // read the imgInfo structures back out of eeprom,
   // or 'BOOTDRV.CFG' if present (gets precidence)
#if (PLATFORM==PLATFORM_PIC)
   strcpypgm2ram((char*)globalData, (const rom far char*)"BOOTDRV.CFG");
#elif (PLATFORM==PLATFORM_AVR)
	strcpy_P((char*)&globalData[0],PSTR("BOOTDRV.CFG"));
#endif


   // try to read the boot config file
   //
   res = f_open(&fil, (const char*)globalData, FA_READ|FA_OPEN_EXISTING);
   if (!res)
   {
      UINT temp;
      res = f_read(&fil, (void*)(&ii[0]), 4 * sizeof(imgInfo), &temp);
   }
   else
   {
      memset(&ii[0], 0xff, 4 * sizeof(imgInfo));
   }

   for (i = 0; i < 4; ++i)
   {
      if (driveInfo[i].attribs == 0xff || (tryOpenImage(&driveInfo[i]) & 0x40))
      {
         memset(&driveInfo[i], 0xff, sizeof(imgInfo));
      }
   }

   saveDrivesImpl();

   WriteDataPort(STATUS_OK);
}


void wfnSerialiseSDDOSDrives(void)
{
   saveDrivesImpl();
   WriteDataPort(STATUS_OK);
}


// slightly uneasy about using this var, but it should be fine.
//
extern BYTE byteValueLatch;

void wfnUnmountSDDOSImg(void)
{
   imgInfo* image = &driveInfo[byteValueLatch & 3];
   memset(image, 0xff, sizeof(imgInfo));

   saveDrivesImpl();
   WriteDataPort(STATUS_OK);
}


void wfnGetSDDOSImgNames(void)
{
   BYTE i;
   BYTE m, n = 0;
   for (i = 0; i < 4; ++i)
   {
      if (driveInfo[i].attribs != 0xff)
      {
         m = 0;

         while(driveInfo[i].filename[m] && m < 12)
         {
            globalData[n] = driveInfo[i].filename[m];
            ++m;
            ++n;
         }
      }
      globalData[n] = 0;
      ++n;
   }

   WriteDataPort(STATUS_OK);
}


#endif



#define MK_WORD(x,y) ((WORD)(x)<<8|(y))

// Read Eeprom
#define COM_RE MK_WORD('R','E')

// Write Eeprom
#define COM_WE MK_WORD('W','E')


void wfnExecuteArbitrary(void)
{
   if (globalAmount == 0 && globalDataPresent == 0)
   {
      WriteDataPort(STATUS_COMPLETE | ERROR_NO_DATA);
      return;
   }

   switch (LD_WORD(&globalData[0]))
   {
   case COM_RE: // read eeprom
      {
         // globalData[2] = start offset, [3] = count

         WORD start = (WORD)globalData[2];
         WORD end = start + (WORD)globalData[3];

         WORD i, n = 0;
         for (i = start; i < end; ++i, ++n)
         {
            globalData[n] = ReadEEPROM(i);
         }

         WriteDataPort(STATUS_OK);
      }
      break;

   case COM_WE: // write eeprom
      {
         // globalData[2] = start offset, [3] = count

         WORD start = (WORD)globalData[2];
         WORD end = start + (WORD)globalData[3];

         WORD i, n = 4;
         for (i = start; i < end; ++i, ++n)
         {
            WriteEEPROM(i,globalData[n]);
         }

         WriteDataPort(STATUS_OK);
      }
      break;
   }
}
