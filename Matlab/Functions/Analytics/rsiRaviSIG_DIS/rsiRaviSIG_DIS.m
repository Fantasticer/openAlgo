function varargout = rsiRaviSIG_DIS(price,rsiM,rsiThresh,rsiType,...
                                    raviF,raviS,raviD,raviM,raviE,raviThresh,...
                                    bigPoint,cost,scaling)
%RSIRAVISIG_DIS RSI signal generation with a RAVI based transformer
%   RSI is an Overbought | Oversold indicator.  Trending markets that of Over-bought|sold can become
%   significantly more Over-B|S.
%   RAVI is an indicator that shows whether a market is in a ranging or a trending phase.
%
%   By using a RAVI transformer on an RSI signal, we should have a noticable improvement on the
%   resulting performance.
%
%   This produces a logically valid signal output
%
%   rsiM:           RSI lookback
%   rsiThresh:      RSI Overbought | Oversold threshold
%   rsiType:        RSI average type (default = 0)
%   raviF:          RAVI lead moving average period (default = 5)
%   raviS:          RAVI lag moving average period  (default = 65)
%   raviD:          RAVI denominator (0: MA (default)   1: ATR)
%   raviM:          RAVI mean shift (default = 20)
%   raviE:          RAVI effects
%                       Effect 0: Remove the signal in trending markets (default = 0)
%                       Effect 1: Remove the signal in ranging markets
%                       Effect 2: Reverse the signal in trending markets
%                       Effect 3: Reverse the signal in ranging markets
%   raviThresh:     RAVI threshold where the market changes from Ranging to Trending (default UNKNOWN)
%                   We are uncertain of a good raviThresh reading.  We need to sweep for this and update
%                   with our findings.  Recommended sweep is similar to RSI percentage [10:5:40]
%

%% NEED TO ADD ERROR CHECKING OF INPUTS
%% Defaults
if ~exist('rsiM','var'), rsiM = [14 0]; end;
if ~exist('rsiThresh','var'), rsiThresh = 65; end;
if ~exist('rsiType','var'), rsiType = 0; end;
if ~exist('raviF','var'), raviF = 5; end;
if ~exist('raviS','var'), raviS = 65; end;
if ~exist('raviD','var'), raviD = 0; end;
if ~exist('raviM','var'), raviM = 20; end;
if ~exist('raviE','var'), raviE = 0; end;
if ~exist('raviThresh','var'), raviThresh = 10; end;
if ~exist('scaling','var'), scaling = 1; end;
if ~exist('cost','var'), cost = 0; end;         % default cost
if ~exist('bigPoint','var'), bigPoint = 1; end; % default bigPoint

if length(rsiM) == 1
    rsiM = [15*rsiM rsiM];
end; %if

fClose = OHLCSplitter(price);

[SIG, R, SH, RI, RAV] = rsiRaviSIG_mex(price,rsiM,rsiThresh,rsiType,...
                                    raviF,raviS,raviD,raviM,raviE,raviThresh,...
                                    bigPoint,cost,scaling);

%% Plot if requested
if nargout == 0
    
    % Center plot window basis monitor (single monitor calculation)
    scrsz = get(0,'ScreenSize');
    figure('Position',[scrsz(3)*.15 scrsz(4)*.15 scrsz(3)*.7 scrsz(4)*.7])
    
    % Each element must be the same length - nonsense - thanks MatLab
    % http://www.mathworks.com/help/matlab/matlab_prog/cell-arrays-of-strings.html
    layout = ['3';'2';'1';'3';'5'];
    hSub = cellstr(layout);
    rsiSIG_DIS(price,rsiM,rsiThresh,rsiType,bigPoint,cost,scaling,hSub);
    
    layout = ['3';'2';'4'];
    hSub = cellstr(layout);
    ravi_DIS(price,raviF,raviS,raviD,raviM,hSub);
    
    ax(1) = subplot(3,2,2);
    plot(fClose);
    axis (ax(1),'tight');
    grid on
    legend('Price','Location', 'NorthWest')
    title(['RSI & RAVI, Sharpe Ratio = ',num2str(SH,3)])
    
    ax(2) = subplot(3,2,6);
    plot([SIG,cumsum(R)]), grid on
    legend('Position','Cumulative Return','Location','North')
    title(['Final Return = ',thousandSepCash(sum(R))])
    linkaxes(ax,'x')
else
    %% Return values
    for ii = 1:nargout
        switch ii
            case 1
                varargout{1} = SIG; % signal
            case 2
                varargout{2} = R; % return (pnl)
            case 3
                varargout{3} = SH; % sharpe ratio
            case 4
                varargout{4} = RI; % rsi signal
            case 5
                varargout{5} = RAV; % RAVI
            otherwise
                warning('RSIRAVI:OutputArg',...
                    'Too many output arguments requested, ignoring last ones');
        end %switch
    end %for
end% if

%%
%   -------------------------------------------------------------------------
%                                  _    _ 
%         ___  _ __   ___ _ __    / \  | | __ _  ___   ___  _ __ __ _ 
%        / _ \| '_ \ / _ \ '_ \  / _ \ | |/ _` |/ _ \ / _ \| '__/ _` |
%       | (_) | |_) |  __/ | | |/ ___ \| | (_| | (_) | (_) | | | (_| |
%        \___/| .__/ \___|_| |_/_/   \_\_|\__, |\___(_)___/|_|  \__, |
%             |_|                         |___/                 |___/
%   -------------------------------------------------------------------------
%        This code is distributed in the hope that it will be useful,
%
%                      	   WITHOUT ANY WARRANTY
%
%                  WITHOUT CLAIM AS TO MERCHANTABILITY
%
%                  OR FITNESS FOR A PARTICULAR PURPOSE
%
%                          expressed or implied.
%
%   Use of this code, pseudocode, algorithmic or trading logic contained
%   herein, whether sound or faulty for any purpose is the sole
%   responsibility of the USER. Any such use of these algorithms, coding
%   logic or concepts in whole or in part carry no covenant of correctness
%   or recommended usage from the AUTHOR or any of the possible
%   contributors listed or unlisted, known or unknown.
%
%   Any reference of this code or to this code including any variants from
%   this code, or any other credits due this AUTHOR from this code shall be
%   clearly and unambiguously cited and evident during any use, whether in
%   whole or in part.
%
%   The public sharing of this code does not relinquish, reduce, restrict or
%   encumber any rights the AUTHOR has in respect to claims of intellectual
%   property.
%
%   IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
%   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
%   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
%   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
%   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
%   ANY WAY OUT OF THE USE OF THIS SOFTWARE, CODE, OR CODE FRAGMENT(S), EVEN
%   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%   -------------------------------------------------------------------------
%
%                             ALL RIGHTS RESERVED
%
%   -------------------------------------------------------------------------
%
%   Author:        Mark Tompkins
%   Revision:      4906.24976
%   Copyright:     (c)2013
%


